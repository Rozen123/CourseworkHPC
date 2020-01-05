#include <stdio.h>
#include <cuda_runtime_api.h>
#include <time.h>
/****************************************************************************
  This program gives an example of a poor way to implement a password cracker
  in CUDA C. It is poor because it acheives this with just one thread, which
  is obviously not good given the scale of parallelism available to CUDA
  programs.
  
  The intentions of this program are:
    1) Demonstrate the use of __device__ and __global__ functions
    2) Enable a simulation of password cracking in the absence of library 
       with equivalent functionality to libcrypt. The password to be found
       is hardcoded into a function called is_a_match.   

  Compile and run with:
    nvcc -o cudapass71 cudapass71.cu
    ./cudapass71
   
  Dr Kevan Buckley, University of Wolverhampton, 2018
*****************************************************************************/

/****************************************************************************
  This function returns 1 if the attempt at cracking the password is 
  identical to the plain text password string stored in the program. 
  Otherwise,it returns 0.
*****************************************************************************/

__device__ int is_a_match(char *attempt) {
	char plain_password1[] = "AB1234";
	char plain_password2[] = "CD2345";
	char plain_password3[] = "EF3456";
	char plain_password4[] = "GH4567";


	char *b = attempt;
	char *i = attempt;
	char *n = attempt;
	char *o = attempt;
	char *b1 = plain_password1;
	char *i2 = plain_password2;
	char *n3 = plain_password3;
	char *o4 = plain_password4;

	while(*b == *b1) { 
		if(*b == '\0') 
		{
			printf("Password: %s\n",plain_password1);
			break;
		}

		b++;
		b1++;
	}
	
	while(*i == *i2) { 
		if(*i == '\0') 
		{
			printf("Password: %s\n",plain_password2);
			break;
		}

		i++;
		i2++;
	}

	while(*n == *n3) { 
		if(*n == '\0') 
		{
			printf("Password: %s\n",plain_password3);
			break;
		}

		n++;
		n3++;
	}

	while(*o == *o4) { 
		if(*o == '\0') 
		{
			printf("Password: %s\n",plain_password4);
			return 1;
		}

		o++;
		o4++;
	}
	return 0;

}

__global__ void  kernel() {
	char i1,i2,i3,i4;

	char password[7];
	password[6] = '\0';

	int i = blockIdx.x+65;
	int j = threadIdx.x+65;
	char firstMatch = i; 
	char secondMatch = j; 

	password[0] = firstMatch;
	password[1] = secondMatch;
	for(i1='0'; i1<='9'; i1++){
		for(i2='0'; i2<='9'; i2++){
			for(i3='0'; i3<='9'; i3++){
				for(i4='0'; i4<='9'; i4++){
					password[2] = i1;
					password[3] = i2;
					password[4] = i3;
					password[5] = i4; 
					if(is_a_match(password)) {
					} 
					else {
	     			//printf("tried: %s\n", password);		  
					}
				}
			}
		}
	}
}

// Calculate the difference between two times. Returns zero on
// success and the time difference through an argument. It will 
// be unsuccessful if the start time is after the end time.

int time_difference(struct timespec *start, 
                    struct timespec *finish, 
                    long long int *difference) {
  long long int d_sec =  finish->tv_sec - start->tv_sec; 
  long long int d_nsec =  finish->tv_nsec - start->tv_nsec; 

  if(d_nsec < 0 ) {
    d_sec--;
    d_nsec += 1000000000; 
  } 
  *difference = d_sec * 1000000000 + d_nsec;
  return !(*difference > 0);
}


int main() {

	struct  timespec start, finish;
	long long int time_elapsed;
	clock_gettime(CLOCK_MONOTONIC, &start);

	kernel <<<26,26>>>();
	cudaThreadSynchronize();

	clock_gettime(CLOCK_MONOTONIC, &finish);
	time_difference(&start, &finish, &time_elapsed);
	printf("Time elapsed was %lldns or %0.9lfs\n", time_elapsed, (time_elapsed/1.0e9)); 

	return 0;
}


