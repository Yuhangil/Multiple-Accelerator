#include <stdio.h>
#include "xparameters.h"
#include "xil_io.h"
#include "xtime_l.h"
#include <stdlib.h>
#include <assert.h>

#define AXI_DATA_BYTE 4
#define IDLE 1
#define RUN 1 << 1
#define DONE 1 << 2

#define CTRL_REG 0
#define STATUS_REG 1
#define MEM0_ADDR_REG 2
#define MEM0_DATA_REG 3
#define MEM1_ADDR_REG 4
#define MEM1_DATA_REG 5

#define MEM_DEPTH 4096
#define NUM_CORE 2

int main(void)
{
	int i;
	int j;
	int status;
	XTime tStart, tEnd;
	unsigned int *Gen_Data;
	unsigned int *hw_result;
	unsigned int *sw_result;
	unsigned char A[2];
	unsigned char B[2];
	unsigned short C[2];
	double hw_time = 0;
	Gen_Data = (unsigned int*) calloc(1, sizeof(unsigned int) * MEM_DEPTH);
	hw_result = (unsigned int*) calloc(1, sizeof(unsigned int) * MEM_DEPTH);
	sw_result = (unsigned int*) calloc(1, sizeof(unsigned int) * MEM_DEPTH);


	printf("Data Gen\n");
	srand(2001);

	for(i=0;i<MEM_DEPTH;i++)
	{
		for(j=0;j<NUM_CORE;j++)
		{
			A[j] = rand()%256;
			B[j] = rand()%256;
		}
		Gen_Data[i] |= A[0];
		Gen_Data[i] = Gen_Data[i] << 8;
		Gen_Data[i] |= B[0];
		Gen_Data[i] = Gen_Data[i] << 8;
		Gen_Data[i] |= A[1];
		Gen_Data[i] = Gen_Data[i] << 8;
		Gen_Data[i] |= B[1];
	}
	printf("Gen End\n");
	XTime_GetTime(&tStart);
	for(i=0;i<MEM_DEPTH;i++)
	{
		A[0] = (Gen_Data[i] & 0xFF000000) >> 24;
		B[0] = (Gen_Data[i] & 0x00FF0000) >> 16;
		A[1] = (Gen_Data[i] & 0x0000FF00) >> 8;
		B[1] = (Gen_Data[i] & 0x000000FF);
		C[0] = A[0] * B[0];
		C[1] = A[1] * B[1];

		sw_result[i] = C[0];
		sw_result[i] = sw_result[i] << 16;
		sw_result[i] |= C[1];
	}
	XTime_GetTime(&tEnd);
	printf("SW Done\n");
	printf("Output took %llu clock cycles\n", 2*(tEnd-tStart));
	printf("OUtput took %.2f us.\n", 1.0 * (tEnd-tStart) / (COUNTS_PER_SECOND/1000000));



	XTime_GetTime(&tStart);
	Xil_Out32((XPAR_MULACCEL_0_BASEADDR) + (CTRL_REG*AXI_DATA_BYTE), (u32)(0));
	Xil_Out32((XPAR_MULACCEL_0_BASEADDR) + (MEM0_ADDR_REG*AXI_DATA_BYTE), (u32)(0x00000000));
	for(i=0;i<MEM_DEPTH;i++)
	{
		Xil_Out32((XPAR_MULACCEL_0_BASEADDR) + (MEM0_DATA_REG*AXI_DATA_BYTE), Gen_Data[i]);
	}
	XTime_GetTime(&tEnd);
	hw_time += 1.0 * (tEnd-tStart) / (COUNTS_PER_SECOND/1000000);
	printf("Bram0 Write Done\n");
	printf("Output took %llu clock cycles\n", 2*(tEnd-tStart));
	printf("OUtput took %.2f us.\n", 1.0 * (tEnd-tStart) / (COUNTS_PER_SECOND/1000000));



	XTime_GetTime(&tStart);
	do
	{
		status = Xil_In32((XPAR_MULACCEL_0_BASEADDR) + (STATUS_REG*AXI_DATA_BYTE));
		printf("%x\n", status);

	} while((status & IDLE) != IDLE);
	Xil_Out32((XPAR_MULACCEL_0_BASEADDR) + (CTRL_REG * AXI_DATA_BYTE), (u32)(MEM_DEPTH | 0x80000000));
	do
	{
		printf("Done .. Done..\n");
		status = Xil_In32((XPAR_MULACCEL_0_BASEADDR) + (STATUS_REG*AXI_DATA_BYTE));

	} while((status & DONE) != DONE);
	XTime_GetTime(&tEnd);
	hw_time += 1.0 * (tEnd-tStart) / (COUNTS_PER_SECOND/1000000);

	printf("Core Done\n");
	printf("Output took %llu clock cycles\n", 2*(tEnd-tStart));
	printf("OUtput took %.2f us.\n", 1.0 * (tEnd-tStart) / (COUNTS_PER_SECOND/1000000));

	XTime_GetTime(&tStart);
	Xil_Out32((XPAR_MULACCEL_0_BASEADDR) + (MEM1_ADDR_REG * AXI_DATA_BYTE), (u32)(0x00000000));
	for(i=0;i<MEM_DEPTH;i++)
	{
		hw_result[i] = Xil_In32((XPAR_MULACCEL_0_BASEADDR) + (MEM1_DATA_REG * AXI_DATA_BYTE));
	}
	XTime_GetTime(&tEnd);
	hw_time += 1.0 * (tEnd-tStart) / (COUNTS_PER_SECOND/1000000);
	printf("Bram1 Done\n");
	printf("Output took %llu clock cycles\n", 2*(tEnd-tStart));
	printf("OUtput took %.2f us.\n", 1.0 * (tEnd-tStart) / (COUNTS_PER_SECOND/1000000));



	for(i=0;i<MEM_DEPTH;i++)
	{
		if(hw_result[i] != sw_result[i])
		{
			printf("%d : SW : [%d] HW : [%d]\n", i, sw_result[i], hw_result[i]);
		}
	}
	printf("HW Took %.2fus.\n", hw_time);
	printf("Match Succecc?");

	free(Gen_Data);
	free(sw_result);
	free(hw_result);
}
