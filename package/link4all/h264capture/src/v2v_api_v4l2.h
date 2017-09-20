/*
 * my_v4l2.h
 *
 *  Created on: Mar 26, 2012
 *      Author: huhaifeng, huhaifeng@visionvera.com
 */
 
#ifndef V2V_API_V4L2_H_
#define V2V_API_V4L2_H_

#define VIDEO_WIDTH  1280
#define VIDEO_HEIGHT 720
#define MAX_CAM_RES 32 //camres res
#define BUFFER_COUNT 4 //buffer zone
//#define FPS 30 //frame rate
#define FPS 30
#define MAX_CAM_RES 32
#define CAMERA_DEVICE "/dev/video1"
#define CAPTURE_FILE "a.h264"

#define exit_error(s)\
	do{\
		printf("%s is error\n",s);\
		return (-1);\
		}while(0)


/*********************************
*  NAME:VideoBuffer  struct
*  Function: Describe buffer V4L2 driver assigns and maps
*  Member:  start: point of buffer
*  					length: total length of buffer
**********************************/
typedef struct Video_Buffer
{
    void *start;
    int length;
}VideoBuffer;
/*******************************
*  nan=me :fream_buffer
*  Function: save fream
*	 member: buf :point of buf
*					length:total length op buf
********************************/
typedef struct Fream_Buffer
{
	char buf[1843200];
	int length;
	
}FreamBuffer;
/************************************
*		name:CamRes
*		Function:CamRes format
*		Member: width : format width
*						height: format height 
*/
typedef struct CamRes 
	{
		int width;
		int height;
	}CamRes;
/*************************************
*		name:CamResList struct
*		Function:CamRes  format list
*		Member:  cam_res :struct CamRes
						  res_num:camres format number		
*/
typedef struct CamResList
{
	struct CamRes *cam_res;
	int res_num;
}CamResList;

/**********************************
*
*
***********************************/

/*************************************
*		Name:open_device Function
*		Function:open the device
*/
void v2v_module_v4l2_open_device();

/*************************************
*		name:device_init
*		Function:Initial Camera v4l2 
*/
int v2v_module_v4l2_device_init();

/*************************************
*		name: init_mmap
*		Function: mmap 
*/
int v2v_module_v4l2_init_mmap();

/************************************
*		name:start_capturing
*		Function: starting Capture Options 
*/
int v2v_module_v4l2_start_capturing();

/************************************
*		name:stop_capturing
*		Function: stop Capture Options
*/
int v2v_module_v4l2_stop_capturing();

/************************************
*		name :device_uinit
*		Function:uinit device
*/
int v2v_module_v4l2_device_uinit();
/************************************
*		name :v2v_module_v4l2_get_fream
*		Function:save device_stream data;
*/
int v2v_module_v4l2_get_fream(FreamBuffer *freambuf);
#endif /*MY_V4L2_H*/
