#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <errno.h>
#include <pthread.h>

#include "pdebug.h"
#include "mempool.h"

#define PDEBUG_POOL_ST(pool) if (pool) PDEBUG("[total %d, alloced %d]", pool->nr_total, pool->nr_curr)

#define MEMORY_ALIGN(len) (((len) + sizeof (size_t) - 1)	\
			   & (size_t) ~(sizeof (size_t) - 1))

static inline void memory_pool_lock(memory_pool_t* pool) {
	if (pool->uselock) pthread_mutex_lock(&pool->lock);
}
static inline void memory_pool_unlock(memory_pool_t* pool) {
	if (pool->uselock) pthread_mutex_unlock(&pool->lock);
}

static size_t aligned_datasize(size_t objsize)
{
	if (objsize < MEMORY_POOL_DATA_MIN_SIZE) {
		objsize = MEMORY_POOL_DATA_MIN_SIZE;
	}
	return MEMORY_ALIGN(objsize);
}

static size_t aligned_pagesize(size_t objsize, int page_n_obj)
{
	size_t pagesize = MEMORY_POOL_DATA_MIN_SIZE + objsize * page_n_obj;
	return MEMORY_ALIGN(pagesize);
}

static int memory_pool_alloc_one_page(memory_pool_t* pool)
{
	/* after pool->cur += pool->datasize */
	/* assert(!pool->page || pool->cur >= pool->page + pool->pagesize); */
	memory_pool_data_t* p = malloc(pool->pagesize);
	if (!p) return -1;
	p->next = pool->page;
	pool->page = p;
	pool->cur = (p + 1);
	return 0;
}

memory_pool_t* memory_pool_new(size_t objsize, int page_n_obj, int uselock)
{
	PDEBUG("%s(objsize = %ld, page_n_obj = %d, uselock = %d)",
	       __FUNCTION__, objsize, page_n_obj, uselock);
	memory_pool_t* pool = malloc(sizeof(memory_pool_t));
	pool->datasize = aligned_datasize(objsize);
	pool->pagesize = aligned_pagesize(pool->datasize, page_n_obj);
	pool->uselock = (uselock ? 1 : 0);
	pool->page = pool->cur = pool->free = NULL;
	/* if (pool->uselock) pthread_mutex_init(lock, NULL); */
	pool->nr_total = pool->nr_curr = 0;
	/* do NOT pre-allocating pages */
	/* if (memory_pool_alloc_one_page(pool) < 0) { */
	/* 	free(pool); */
	/* 	pool = NULL; */
	/* } */
	PDEBUG(" = %p", pool);
	if (pool) PDEBUG(" [datasize = %ld, pagesize = %ld]", pool->datasize, pool->pagesize);
	PDEBUG_ERRNO(pool != NULL);
	return pool;
}

void memory_pool_del(memory_pool_t* pool)
{
	PDEBUG("%s(pool = %p) ", __FUNCTION__, pool);
	PDEBUG_POOL_ST(pool);
	if (!pool) return;
	memory_pool_data_t* p = pool->page;
	while (p) {
		memory_pool_data_t* cur = p;
		p = p->next;
		free(cur);
	}
	free(pool);
	PDEBUG("\n");
}

static void* memory_pool_alloc_on_free_list(memory_pool_t* pool)
{
	if (!pool->free) return NULL;
	void* p = pool->free;
	pool->free = pool->free->next;
	pool->nr_curr++;
	return p;
}

static void* memory_pool_alloc_on_cur_page(memory_pool_t* pool)
{
	void *p = pool->cur;
	void *end = p + pool->datasize;
	void *pageend = (void*)pool->page + pool->pagesize;
	if (p == NULL || end > pageend) return NULL;
	pool->cur = end;
	pool->nr_total++;
	pool->nr_curr++;
	return p;
}

void* memory_pool_alloc(memory_pool_t* pool)
{
	PDEBUG("%s(pool = %p)", __FUNCTION__, pool);
	/* PDEBUG_POOL_ST(pool); */
	void* p = NULL;
	memory_pool_lock(pool);
	if ((p = memory_pool_alloc_on_free_list(pool)) != 0) {
		goto end;
	}
	if ((p = memory_pool_alloc_on_cur_page(pool)) != 0) {
		goto end;
	}
	if (memory_pool_alloc_one_page(pool) < 0) {
		goto end;
	}
	if ((p = memory_pool_alloc_on_cur_page(pool)) != 0) {
		goto end;
	}
end:
	memory_pool_unlock(pool);
	PDEBUG(" = %p", p);
	/* PDEBUG_POOL_ST(pool); */
	PDEBUG_ERRNO(p != NULL);
	return p;
}

/* return memory to pool: assume obj is allocated by memory_pool_alloc() */
void memory_pool_free(memory_pool_t* pool, void* obj)
{
	PDEBUG("%s(pool = %p, obj = %p)", __FUNCTION__, pool, obj);
	/* PDEBUG_POOL_ST(pool); */
	if (obj == NULL) return;
	memory_pool_data_t* p;
	memory_pool_lock(pool);
	p = obj;
	p->next = pool->free;
	pool->free = p;
	pool->nr_curr--;
	memory_pool_unlock(pool);
	/* PDEBUG_POOL_ST(pool); */
	PDEBUG("\n");
}

