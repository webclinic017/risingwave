use std::collections::{btree_map, BTreeMap};
use std::mem::size_of_val;
use std::sync::Arc;

use async_trait::async_trait;
use bytes::Bytes;
use lazy_static::lazy_static;
use risingwave_common::error::Result;
use tokio::sync::Mutex;

use crate::monitor::{StateStoreStats, DEFAULT_STATE_STORE_STATS};
use crate::{StateStore, StateStoreIter};

/// An in-memory state store
#[derive(Clone)]
pub struct MemoryStateStore {
    inner: Arc<Mutex<BTreeMap<Bytes, Bytes>>>,

    stats: Arc<StateStoreStats>,
}

impl Default for MemoryStateStore {
    fn default() -> Self {
        Self::new()
    }
}

impl MemoryStateStore {
    pub fn new() -> Self {
        Self {
            inner: Arc::new(Mutex::new(BTreeMap::new())),
            stats: DEFAULT_STATE_STORE_STATS.clone(),
        }
    }

    pub fn shared() -> Self {
        lazy_static! {
            static ref STORE: MemoryStateStore = MemoryStateStore::new();
        }
        STORE.clone()
    }

    /// Verify if the ingested batch does not have duplicated key.
    fn verify_ingest_batch(&self, kv_pairs: &mut Vec<(Bytes, Option<Bytes>)>) -> bool {
        let original_length = kv_pairs.len();
        kv_pairs.sort_by(|(k1, _), (k2, _)| k1.cmp(k2));
        // There should not be duplicated key in one batch
        kv_pairs.dedup_by(|(k1, _), (k2, _)| k1 == k2);
        original_length == kv_pairs.len()
    }

    async fn ingest_batch_inner(&self, mut kv_pairs: Vec<(Bytes, Option<Bytes>)>) -> Result<()> {
        let mut inner = self.inner.lock().await;
        let result = self.verify_ingest_batch(&mut kv_pairs);
        debug_assert!(result);
        for (key, value) in kv_pairs {
            if let Some(value) = value {
                inner.insert(key, value);
            } else {
                inner.remove(&key);
            }
        }
        Ok(())
    }

    pub fn get_stats_ref(&self) -> &StateStoreStats {
        self.stats.as_ref()
    }

    async fn scan_inner(&self, prefix: &[u8], limit: Option<usize>) -> Result<Vec<(Bytes, Bytes)>> {
        let mut data = vec![];
        if limit == Some(0) {
            return Ok(vec![]);
        }
        let inner = self.inner.lock().await;
        for (key, value) in inner.iter() {
            if key.starts_with(prefix) {
                data.push((key.clone(), value.clone()));
                if let Some(limit) = limit {
                    if data.len() >= limit {
                        break;
                    }
                }
            }
        }
        Ok(data)
    }

    async fn reverse_scan_inner(
        &self,
        prefix: &[u8],
        limit: Option<usize>,
    ) -> Result<Vec<(Bytes, Bytes)>> {
        let mut data = vec![];
        if limit == Some(0) {
            return Ok(vec![]);
        }
        let inner = self.inner.lock().await;
        for (key, value) in inner.iter().rev() {
            if key.starts_with(prefix) {
                data.push((key.clone(), value.clone()));
                if let Some(limit) = limit {
                    if data.len() >= limit {
                        break;
                    }
                }
            }
        }
        Ok(data)
    }
}

#[async_trait]
impl StateStore for MemoryStateStore {
    type Iter = MemoryStateStoreIter;

    async fn get(&self, key: &[u8]) -> Result<Option<Bytes>> {
        self.get_stats_ref().get_counts.inc();
        let timer = self.get_stats_ref().get_latency.start_timer();
        let inner = self.inner.lock().await;
        let res = inner.get(key).cloned();
        timer.observe_duration();

        self.get_stats_ref().get_key_size.observe(key.len() as f64);
        if res.is_some() {
            self.get_stats_ref()
                .get_value_size
                .observe(size_of_val(res.as_ref().unwrap()) as f64);
        }

        Ok(res)
    }

    async fn scan(&self, prefix: &[u8], limit: Option<usize>) -> Result<Vec<(Bytes, Bytes)>> {
        self.scan_inner(prefix, limit).await
    }

    async fn reverse_scan(
        &self,
        prefix: &[u8],
        limit: Option<usize>,
    ) -> Result<Vec<(Bytes, Bytes)>> {
        self.reverse_scan_inner(prefix, limit).await
    }

    async fn ingest_batch(&self, kv_pairs: Vec<(Bytes, Option<Bytes>)>, _epoch: u64) -> Result<()> {
        // TODO: actually use epoch and support rollback
        self.ingest_batch_inner(kv_pairs).await
    }

    async fn iter(&self, prefix: &[u8]) -> Result<Self::Iter> {
        #[allow(clippy::mutable_key_type)]
        let snapshot: BTreeMap<_, _> = self
            .inner
            .lock()
            .await
            .iter()
            .filter(|(k, _v)| k.starts_with(prefix))
            .map(|(k, v)| (k.to_owned(), v.to_owned()))
            .collect();

        Ok(MemoryStateStoreIter(snapshot.into_iter()))
    }
}

pub struct MemoryStateStoreIter(btree_map::IntoIter<Bytes, Bytes>);

#[async_trait]
impl StateStoreIter for MemoryStateStoreIter {
    type Item = (Bytes, Bytes);

    async fn next(&mut self) -> Result<Option<Self::Item>> {
        Ok(self.0.next())
    }
}
