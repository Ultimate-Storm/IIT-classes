#include <stdlib.h>
#include <string.h>
#include "hashtable.h"

/* Daniel J. Bernstein's "times 33" string hash function, from comp.lang.C;
   See https://groups.google.com/forum/#!topic/comp.lang.c/lSKWXiuNOAk */
unsigned long hash(char *str) {
  unsigned long hash = 5381;
  int c;

  while ((c = *str++))
    hash = ((hash << 5) + hash) + c; /* hash * 33 + c */

  return hash;
}

hashtable_t *make_hashtable(unsigned long size) {
  hashtable_t *ht = malloc(sizeof(hashtable_t));
  ht->size = size;
  ht->buckets = calloc(sizeof(bucket_t *), size);
  return ht;
}

void ht_put(hashtable_t *ht, char *key, void *val) {
  /* FIXME: the current implementation doesn't update existing entries */
  unsigned int idx = hash(key) % ht->size;
  int key_found = 0;
  bucket_t *it = ht->buckets[idx];
  while (it) {
    if (!strcmp(it->key, key)){
      key_found = 1;
      free(it->key);
      free(it->val);
      it->key = key;
      it->val = val;
      break;
    }
    it = it->next;
  }
  if (!key_found){
    bucket_t *b = malloc(sizeof(bucket_t));
    b->key = key;
    b->val = val;
    b->next = ht->buckets[idx];
    ht->buckets[idx] = b;
  }
}

void *ht_get(hashtable_t *ht, char *key) {
  unsigned int idx = hash(key) % ht->size;
  bucket_t *b = ht->buckets[idx];
  while (b) {
    if (strcmp(b->key, key) == 0) {
      return b->val;
    }
    b = b->next;
  }
  return NULL;
}

void ht_iter(hashtable_t *ht, int (*f)(char *, void *)) {
  bucket_t *b;
  unsigned long i;
  for (i=0; i<ht->size; i++) {
    b = ht->buckets[i];
    while (b) {
      if (!f(b->key, b->val)) {
        return ; // abort iteration
      }
      b = b->next;
    }
  }
}

void free_hashtable(hashtable_t *ht) {
  bucket_t *b;
  unsigned long i;
  for (i=0; i<ht->size; i++) {
    b = ht->buckets[i];
    bucket_t *temp = b;
    while (b) {
        temp = b;
        b = b->next;
        free(temp->key);
        free(temp->val);
        free(temp);
    }
  }
  free(ht->buckets);
  free(ht); // FIXME: must free all substructures!
}

/* TODO */
void  ht_del(hashtable_t *ht, char *key) {
  unsigned int idx = hash(key) % ht->size;
  bucket_t *b = ht->buckets[idx];
  bucket_t *next = b->next;
  if(!strcmp(b->key, key)){
    ht->buckets[idx] = b->next;
    free(b->key);
    free(b->val);
    free(b);
    return;
  }
  while (next){
    if (!strcmp(next->key, key)){
      free(next->key);
      free(next->val);
      b->next = next->next;
      free(next);
      return;
    }
    b = b->next;
    next = next->next;
  }
}

void  ht_rehash(hashtable_t *ht, unsigned long newsize) {
  hashtable_t *nht = make_hashtable(newsize);
  unsigned long i;
  for (i=0; i<ht->size; i++){
    bucket_t * b = ht->buckets[i];
    while (b){
        char *nkey = malloc(strlen(b->key)+1);
        void *nval = malloc(strlen(b->val)+1);
        strcpy(nkey, b->key);
        strcpy(nval, b->val);
        ht_put(nht, nkey, nval);
        bucket_t *temp = b;
        b = b->next;
        free(temp->key);
        free(temp->val);
        free(temp);
    }
  }
  free(ht->buckets);
  ht->buckets = nht->buckets;
  ht->size = nht->size;
  free(nht);
}
