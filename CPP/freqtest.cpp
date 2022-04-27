#include <Rcpp.h>
using namespace Rcpp;
using namespace std;

// This is a simple example of exporting a C++ function to R. You can
// source this function into an R session using the Rcpp::sourceCpp
// function (or via the Source button on the editor toolbar). Learn
// more about Rcpp at:
//
//   http://www.rcpp.org/
//   http://adv-r.had.co.nz/Rcpp.html
//   http://gallery.rcpp.org/
//

// switch(alternative, less = pbinom(x, n, p), greater = pbinom(x -
//        1, n, p, lower.tail = FALSE),
//
double binom_test_upp(const int x_, const int n_, const double p_){
  // double res=2*(R::pbinom(x_,n_,1-p_,true, false));
  double res=R::pbinom(x_-1,n_,p_,false, false);
  return(res);
}
double binom_test_low(const int x_, const int n_, const double p_){
  double res=R::pbinom(x_,n_,p_,true, false);
return(res);
}

// [[Rcpp::export]]
NumericMatrix freqtest(NumericMatrix x,
              NumericMatrix n,
              NumericMatrix p) {
  int M, N, i, j;
  M=x.nrow();
  N=x.ncol();
  NumericMatrix res(M,N);
  double tmp=0;
  for ( i=0; i<N; i++ ){
    for ( j=0; j<M; j++ ){
      if(n(j,i) ==0){
        tmp= -9;
      }
      else if(x(j,i)/n(j,i) >= p(j,i)){
        tmp = binom_test_upp(x(j,i),n(j,i),p(j,i));
      }
      else if(x(j,i)/n(j,i) < p(j,i)){
        tmp = binom_test_low(x(j,i),n(j,i),p(j,i));
      }
      else{
        tmp = -9;
      }
      res(j,i)=tmp;
    }
  }
  return(res);
  // return(1);
}

// You can include R code blocks in C++ files processed with sourceCpp
// (useful for testing and development). The R code will be automatically
// run after the compilation.
//

/*** R
x=matrix(c(5,10,20,25),nrow=2,ncol=2)
n=matrix(c(30,30,30,30),nrow=2,ncol=2)
x=matrix(c(0,10,20,30),nrow=2,ncol=2)
n=matrix(c(30,30,30,30),nrow=2,ncol=2)
x=matrix(c(1,10,20,30),nrow=2,ncol=2)
n=matrix(c(1,10,20,30),nrow=2,ncol=2)

p=matrix(c(0.5,0.5,0.5,0.5),nrow=2,ncol=2)
testfun<-freqtest(x,n,p)

res1<-matrix(ncol=2,nrow=2)
for(i in 1:2){
  for(j in 1:2){
    res1[j,i]=(binom.test(x[j,i], n[j,i], p[j,i], alternative="two.sided")$p.val)
  }
}
res2=freqtest(x,n,p)
cbind(c(res1),c(res2))

pbinom(19,30,0.5)
binom.test(19, 30, 0.5, alternative="greater")$p.value
freqtest(matrix(c(19,19)),matrix(c(30,30)),matrix(c(0.5,0.5)))

binom.test(0, 30, 0.5, alternative="greater")$p.value
binom.test(0, 30, 0.5, alternative="less")$p.value
freqtest(matrix(c(0,30)),matrix(c(30,30)),matrix(c(0.5,0.5)))

#
# binom.test(10, 30, 0.5, alternative="less")$p.value
# pbinom(10,30,0.5)
#
binom.test(20, 30, 0.5, alternative="two.sided")$p.value
(1-pbinom(19,30,0.5)) *2

# binom.test(10, 30, 0.5, alternative="two.sided")$p.value
# (pbinom(10,30,0.5)) *2


*/
