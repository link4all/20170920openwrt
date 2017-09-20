#ifndef STATIC_MEMORY_POOL_H
#define STATIC_MEMORY_POOL_H

#include <sys/types.h>
#include <pthread.h>

typedef union memory_pool_data {
	union memory_pool_data* next; /* pointer to next page when freed */
	char data[0];		      /* real data when allocated */
} memory_pool_data_t;

#define MEMORY_POOL_DATA_MIN_SIZE	sizeof(memory_pool_data_t)
#define MEMORY_POOL_DEFAULT_PAGE_SIZE	1024 /* 1k */

/* unlimited memory pool, with or without lock,
 * never freed until del or program end */
typedef struct memory_pool {
	/* options */
	size_t datasize; /* allocate() returned datasize */
	size_t pagesize; /* malloc()ed size if poll run outof memory */
	unsigned int uselock : 1; /* use lock */
	/* allocating structures  */
	memory_pool_data_t *page;	/* current allocating page, size = pagesize */
	memory_pool_data_t *cur;	/* current allocating position in the page */
	memory_pool_data_t *free;	/* linklist of free data */
	pthread_mutex_t lock;	/* if locked alloc */
	/* statistics */
	int nr_total;		/* total allocated */
	int nr_curr;		/* current allocated */
} memory_pool_t;

/* new pool:  */
memory_pool_t* memory_pool_new(size_t objsize, int page_n_obj, int use_lock);
/* del pool */
void memory_pool_del(memory_pool_t* pool);

/* alloc memory on pool: failed only if malloc() failed (ENOMEM) */
void* memory_pool_alloc(memory_pool_t* pool);

/* return memory to pool: assume obj is allocated by memory_pool_alloc() */
void memory_pool_free(memory_pool_t* pool, void* obj);

#endif
