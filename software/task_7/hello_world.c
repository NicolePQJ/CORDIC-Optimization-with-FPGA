#include <stdlib.h>
#include <sys/alt_stdio.h>
#include <sys/alt_alarm.h>
#include <sys/times.h>
#include <alt_types.h>
#include <system.h>
#include <unistd.h>
#include <stdio.h>
#include <time.h>
#include <math.h>

//Test case 1
//#define step 5.0
//#define N 52

//Test case 2
//
#define step 1/8.0
//
#define N 2041
//#define N 150
//Test case 3
//#define step 1/1024.0
//#define N 261121

#define ALT_CI_ADD_0(A,B) __builtin_custom_fnff(ALT_CI_ADD_0_N,(A),(B))
#define ALT_CI_ADD_0_N 0x1
#define ALT_CI_EVAL_2_0(A,B) __builtin_custom_fnff(ALT_CI_EVAL_2_0_N,(A),(B))
#define ALT_CI_EVAL_2_0_N 0x0

//Generate the vector x and stores it in the memory
void generateVector(float x[N])
{
	int i;
	x[0] = 0;
	for (i=1; i<N; i++){
		x[i] = x[i-1] + step;
	}
}

float EvalFx(float x[], int M) {
	float y = 0.0f;
	float datab;
	float dataa;
	//int a = M+15;
	for (int i=0; i<M; i++){
		if (i==0){
			datab = -1.0f;
			//dataa = x[i];
		}
		else if (i==M-1){
			datab = -1.0f;
			//dataa = 0.0;
		}
		else{
			datab = 0.0f;
			datab = -1.0f;
			//dataa = x[i];
		}
		//printf("datab:%f\n", datab);
		float tmp = ALT_CI_EVAL_2_0(x[i], datab);
		y = ALT_CI_ADD_0(tmp,y);

		//printf("Result:%f\n", y);
	}
	return y;
}

int main()
{
  printf("Task 2\n");

  //define input vector
  float x[N];//= {0.25,0.3,0.4,0.5};
  //define result
  float y;

  generateVector(x);

  //for timing
  char buf[50];
  clock_t exec_t1, exec_t2;

  exec_t1 = times(NULL);

  y = EvalFx(x,N);

  //y = sumVector(x,N);
  //y = sumVector(x,N);


  exec_t2 = times(NULL);


  //gcvt((exec_t2 - exec_t1)*1000/CLOCKS_PER_SEC, 10, buf);
  //
  gcvt(exec_t2 - exec_t1, 10, buf);
  alt_putstr(" proc time = ");
  alt_putstr(buf);
  alt_putstr(" ticks \n");
  //printf("proc time = %d ticks \n", (unsigned int) (exec_t2 - exec_t1));


//  int i;
//  for (i = 0; i<10; i++){
//	  y = y/2.0;
//  }
  //float result = ALT_CI_EVAL_2_0(0.4);
  printf("Result:%f\n", y);

  return 0;
}

