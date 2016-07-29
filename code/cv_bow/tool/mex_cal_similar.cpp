#include "mex.h"
#include "cmath"
#include "stdio.h"
using namespace std;

typedef unsigned char uint8;

// 1. 注意如果不是数字类型转换，而是内存类型转换，一旦使用了unsigned，就全部使用unsigned
// 2. matlab 转 c一定要注意mxIsUint8之类的类型判断函数，因为使用内存级的类型转换，所以类型要很严谨，同时prhs[i]的i一定要对上，这些都不会有报错提示

/* 
 * double mex_cal_simialr(uint8* Qd,unsigned long long* Qsig
         uint8* Dd,unsigned long long* Dsig
         double* idf, int threshold, double sigma)
*/

int find_end(int last_end,int k,uint8* d,const int size);
int hamming(unsigned long long a, unsigned long long b);
double cal_simialr(uint8* Qd,unsigned long long* Qsig,const int Qsize, 
        uint8* Dd,unsigned long long* Dsig, const int Dsize,
        double* idf,int K, int threshold, double sigma);

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
    // 检查参数数量
    if(nrhs != 7){
        mexErrMsgTxt("7 input argument required.");
    }else if (nlhs > 1) {
        mexErrMsgTxt("Too many output arguments.");
    } 
    
    // 参数获取
    
    // Qd
    const int* dim_array = mxGetDimensions(prhs[0]);                      // 相当于matlab里的size
    if(dim_array[1] != 1){                         
        mexErrMsgTxt("the length of every row in 1st argumnet Qd must be 1\n");           // 列优先，所以每列必须是64个，即64行
    }
    if(!mxIsUint8(prhs[0])){
        mexErrMsgTxt("the 1st argument Qd must be uint8 array type\n");
    }
    const int Qsize = dim_array[0];
    uint8* Qd = (uint8*) mxGetPr(prhs[0]);
    
    // Qsig
    dim_array = mxGetDimensions(prhs[1]);
    if(dim_array[1] != 1){                         
        mexErrMsgTxt("the length of every row in 2nd argumnet Qsig must be 1\n");           // 列优先，所以每列必须是64个，即64行
    }
    if(!mxIsUint64(prhs[1])){
        mexErrMsgTxt("the 2nd argument Qsig must be uint64 array type\n");
    }
    if(dim_array[0] != Qsize){
         mexErrMsgTxt("the size of Qd and Qsig must be same\n");
    }
    unsigned long long* Qsig =  (unsigned long long*)mxGetPr(prhs[1]);
    
    // Dd
    dim_array = mxGetDimensions(prhs[2]);
    if(dim_array[1] != 1){                         
        mexErrMsgTxt("the length of every row in 3rd argumnet Dd must be 1\n");          
    }
    if(!mxIsUint8(prhs[2])){
        mexErrMsgTxt("the 1st argument Qd must be uint8 array type\n");
    }
    const int Dsize = dim_array[0];
    uint8* Dd = (uint8*) mxGetPr(prhs[2]);
    
    // Dsig
    dim_array = mxGetDimensions(prhs[3]);
    if(dim_array[1] != 1){                         
        mexErrMsgTxt("the length of every row in 4th argumnet Dsig must be 1\n");           
    }
    if(!mxIsUint64(prhs[3])){
        mexErrMsgTxt("the 4th argument Dsig must be uint64 array type\n");
    }
    if(dim_array[0] != Dsize){
         mexErrMsgTxt("the size of Dd and Dsig must be same\n");
    }
    unsigned long long* Dsig =  (unsigned long long*)mxGetPr(prhs[3]);

    // idf
    dim_array = mxGetDimensions(prhs[4]);
    if(dim_array[1] != 1){
        mexErrMsgTxt("the length of every row in 5th argumnet idf must be 1\n");
    }
    if(!mxIsDouble(prhs[4])){
        mexErrMsgTxt("the 5th argument idf must be double array type\n");
    }
    double* idf = mxGetPr(prhs[4]);
    const int K = dim_array[0];
    
    // threshold
    const int threshold = (int)mxGetScalar(prhs[5]);
    const double sigma = mxGetScalar(prhs[6]);
    
    // 输出变量
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
    double* y = mxGetPr(plhs[0]);
    *y = cal_simialr(Qd, Qsig, Qsize, Dd, Dsig, Dsize, idf, K, threshold, sigma);
}

// void printBin(uint8 c){
//     uint8 s[8];
//     for(int i = 7; i >= 0; i--){
//         s[i] = c % 2;
//         c /= 2;
//     }
//     for(int i = 0; i < 8; i++){
//         printf("%x", s[i]);
//     }
//     printf(" ");
// }
// 
// void printBin(unsigned long long num){
//     uint8* s = (uint8*)(&num);
//     for(int i = 7; i >= 0; i--)
//         printBin(s[i]);
//     printf(", ");
// }
// 
// void printHex(unsigned long long num){
//     unsigned char* s = (unsigned char*)(&num);
//     for(int i = 7; i >= 0; i--)
//         printf("%x", s[i]);
//     printf(", ");
// }

double cal_simialr(uint8* Qd,unsigned long long* Qsig,const int Qsize, 
        uint8* Dd,unsigned long long* Dsig, const int Dsize,
        double* idf,int K, int threshold, double sigma){
//     printf("%f", log(10));
    double similar = 0;
    int dis = 0;
    
    int last_end_Q = -1;
    int last_end_D = -1;
    int end_Q,end_D;
    for(int k = 1; k <= K; k++){                                                // matlab从1开始计数
        end_Q = find_end(last_end_Q, k, Qd, Qsize);                         // matlab从1开始计数
        end_D = find_end(last_end_D, k, Dd, Dsize);
        
        for(int i = last_end_Q+1; i <= end_Q; i++){
            for(int j = last_end_D+1; j <= end_D; j++){
//                 printHex(Qsig[i]);
//                 printBin(Qsig[i]);//, Dsig[j]);
// //                 printHex(Dsig[j]);
//                 printBin(Dsig[j]);
                dis = hamming(Qsig[i], Dsig[j]);
//                 printf("%d,", dis);
                if(dis < threshold){
                    //similar += 1;                                 // th=28 rt=0.5577
//                     similar += exp(-dis*dis/sigma/sigma) * idf[k-1] * idf[k-1]; // th=12 rt=0.3029
//                     similar += log(65 - dis) * idf[k-1];         // th=28 rt=0.5673
                    similar +=  1 * idf[k-1] * idf[k-1];         // th=28 rt=0.5673
                }
            }
        }
//         printf("%d \n", k);
        last_end_Q = end_Q;
        last_end_D = end_D;
    }
//     printf("%d %d %d %d\n", Qsize, Dsize, end_Q, end_D);
    //printf("hamming : %d\n", hamming(7002804066039534892L, 16305000044234408364L));
    return similar;
}

// 计算两个uint64的汉明距离
int hamming(unsigned long long a, unsigned long long b){
    int dis = 0;
    unsigned long long c = a ^ b;       // 异或
    for(int i =0; i < 64; i++){
        dis += c & 1;
        c >>= 1;
    }
    return dis;
}

// 找到最后一个等于k的index,没有等于k的就返回last_end
int find_end(int last_end,int k,uint8* d,const int size){
    int end = last_end + 1;
    for(; end < size; end ++){
        if(d[end] > k) break;
    }
    end = end - 1;
    return end;
}
