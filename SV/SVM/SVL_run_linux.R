# setwd("SV/SVM")
rm(list = ls())
library(rjags)
library(coda)
set.seed(1345221)

save_on = TRUE


ada=1000
iter=10000
th=1
cha= 2 #2


mu <- -1
phi <- 0.98
sigma2 <- 0.01
sigma <- sqrt(sigma2)
# nu <- 5;
#beta <- -0.2;
rho <- -0.2 

param <- c(rho, mu, phi, sigma2)

a1 = mu
P1 <- (sigma^2)/(1-phi^2)


################# simultated data ####
T <- 2000
h_true <- rep(NaN,T)
E <- matrix(rnorm(T*2),nrow=T)
V <- matrix(c(1, rho*sigma, rho*sigma, sigma2),ncol=2)
CV <- t(chol(V))
E <- t(CV%*%t(E))
plot(E)
epsilon <- E[,1]
eta <- E[,2]

h_true[1] <- a1 
for (t in c(2:T)){
  h_true[t] = mu + phi*(h_true[t-1]-mu) + eta[t]
}

# y <- beta*exp(h_true) + exp(h_true/2)*rnorm(T)
y <- exp(h_true/2)*epsilon
#y <- exp(h_true/2)*rt(T,nu)
par(mfrow=c(1,1))
plot(y,type='l')
lines(h_true, type='l', col='red')

################# full DA ####

# inits <- function()(list(mu = 0, phi = 0.97, sigma = 0.15, h = var(y)*rep(1,T)))
# inits <- function()(list(mu = 0, phi_star = (0.97+1)/2, sigma2_star = 1/(0.15^2), 
#                          beta = 1, h = log(var(y))*rep(1,T)))
inits <- function()(list(mu = mu, rho = rho, phi_star = (phi+1)/2, 
                         sigma2_star = 1/sigma2, h = log(var(y))*rep(1,T)))
params <- c('mu','sigma2','phi','rho','h')
data <- list(y=y,T=T)

svl_model_string <- "
model{
# define the observation process
for (t in 1:T){
y[t] ~ dnorm(beta*exp(h[t]), 1.0/exp(h[t])) 
}

# define the state process
for (t in 2:T){
h[t] ~ dnorm(mean_h[t],sigma2_star)
mean_h[t] <- mu + phi*(h[t-1] - mu) 
}

h[1] ~ dnorm(mean_h[1],sigma2_star)
mean_h[1] <- mu + phi*(h0 - mu) 

h0 ~ dnorm(mean_h0,1/P1)
P1 <- sigma2/(1-phi^2)
mean_h0 <- mu

# define the priors for parameters
mu ~ dnorm(0,0.1)

# (phi+1)/2 ~ betapdf((phi+1)/2, 20, 1.5)
phi <- 2*phi_star - 1
phi_star ~ dbeta(20, 1.5)
# (phi+1)/2 ~ dbeta(20, 1.5)

# 1/sigma2 ~ gampdf(1./s2, 5/2, 0.05/2);
sigma2 <- 1/sigma2_star
#   sigma2_star ~ dgamma(5/2, 2/0.05) # shape and rate
sigma2_star ~ dgamma(5/2, 0.05/2) # shape and rate
# 1/sigma2  ~  dgamma(5/2, 2/0.05)

beta ~ dnorm(0,1)
}
"

### MAYER MODEL ###

params <- c('mu','phi','tau','rho','theta')
data <- list(Y=y,n=T)
tstart = proc.time()
svl_model_mayer <- jags.model('svl_model_mayer.R',
                           data=data, n.chains = cha, n.adapt = ada)
time_init_mayer = proc.time()-tstart

tstart = proc.time()


tstart = proc.time()
output_svl_DA <- coda.samples(svl_model_mayer, params, n.iter = iter, thin=th)
time_sample_DA = proc.time()-tstart



mat1_DA = as.matrix(output_svl_DA[1]) 
mat2_DA = as.matrix(output_svl_DA[2]) 
mat_names_DA <- colnames(mat1_DA)
# > mat_names_DA[1:4]
# [1] "mu"  "phi" "rho" "tau"
# mat_names_DA[c(4+1,T+4)]
# [1] "theta[1]"    "theta[2000]"

theta1_DA = mat1_DA[,1:4] 
theta2_DA = mat2_DA[,1:4] 

param <- c(mu,phi,rho,sigma)

par(mfrow=c(2,2))
for (i in 1:4){
  plot(theta1_DA[,i],xlab='',ylab='',type='l',main=colnames(theta1_DA)[i])
  lines(theta2_DA[,i],xlab='',ylab='',type='l',col='blue')
  lines(param[i]+0*theta2_DA[,i],xlab='',ylab='',type='l',col='red')
}
colMeans(theta1_DA)
colMeans(theta2_DA)


H_short1_DA = mat1_DA[,4+seq(200,T,by=200)]
H_short2_DA = mat2_DA[,4+seq(200,T,by=200)]


par(mfrow=c(3,3))
for (i in 1:9){
  plot(H_short1_DA[,i],xlab='',ylab='',type='l',main=colnames(H_short1_DA)[i])
  lines(H_short2_DA[,i],xlab='',ylab='',type='l',col='blue')
  lines(h_true[200*i]+0*H_short2_DA[,i],xlab='',ylab='',type='l',col='red')
}



par(mfrow=c(2,2))
for (i in 1:4){
  acf(theta1_DA[,i],xlab='',ylab='',lag=100,main=colnames(theta1_DA)[i])
}

par(mfrow=c(3,3))
for (i in 1:9){
  acf(H_short1_DA[,i],xlab='',ylab='',lag=100,main=colnames(H_short1_DA)[i])
}



### JAGS #####
tstart = proc.time()
svl_model_DA <- jags.model(textConnection(svl_model_string), 
                       data=data, inits=inits, n.chains = cha, n.adapt = ada)
time_init_DA = proc.time()-tstart

tstart = proc.time()
output_svl_DA <- coda.samples(svl_model_DA, params, n.iter = iter, thin=th)
time_sample_DA = proc.time()-tstart

# save selected output

mat1_DA = as.matrix(output_svl_DA[1]) 
mat2_DA = as.matrix(output_svl_DA[2]) 
mat_names_DA <- colnames(mat1_DA)

ESS_DA = lapply(output_svl_DA,effectiveSize)
ESS1_DA = as.matrix(ESS_DA[[1]])
ESS2_DA = as.matrix(ESS_DA[[2]])

theta1_DA = mat1_DA[,c(1,T+1+(1:3))] 
theta2_DA = mat2_DA[,c(1,T+1+(1:3))] 

H_short1_DA = mat1_DA[,1+seq(200,T,by=200)]
H_short2_DA = mat2_DA[,1+seq(200,T,by=200)]

mean_H1_DA = colMeans(mat1_DA[,1+(1:T)])
mean_H2_DA = colMeans(mat2_DA[,1+(1:T)])


if (save_on) {
  save(file=paste("svl_DA_T",toString(T),"_selected.RData",sep=""),
       y, h_true, param, 
       svl_model_DA, time_init_DA, time_sample_DA, mat_names_DA,
       ESS1_DA, ESS2_DA, theta1_DA, theta2_DA, 
       H_short1_DA, H_short2_DA, mean_H1_DA, mean_H2_DA)
}
 
# if (save_on) {
#   save(file=paste("SV_DA_T",toString(T),".RData",sep=""),
#        y, h_true, param, output_sv_DA, sv_model_DA, time_init_DA, time_sample_DA)
# }

quit()



par(mfrow=c(2,2))
for (i in 1:4){
  acf(theta1_DA[,i],xlab='',ylab='',lag=100,main=colnames(theta1_DA)[i])
}

colMeans(theta1_DA)
colMeans(theta2_DA)



par(mfrow=c(2,2))
for (i in 1:4){
  plot(theta1_DA[,i],xlab='',ylab='',type='l',main=colnames(theta1_DA)[i])
  lines(theta2_DA[,i],xlab='',ylab='',type='l',col='blue')
  lines(param[i]+0*theta2_DA[,i],xlab='',ylab='',type='l',col='red')
}


par(mfrow=c(3,3))
for (i in 1:9){
  plot(H_short1_DA[,i],xlab='',ylab='',type='l',main=colnames(H_short1_DA)[i])
  lines(H_short2_DA[,i],xlab='',ylab='',type='l',col='blue')
  lines(h_true[200*i]+0*H_short2_DA[,i],xlab='',ylab='',type='l',col='red')
}



par(mfrow=c(1,1))
plot(mean_H2_DA,xlab='',ylab='',type='l')
lines(h_true, type='l', col='red')
