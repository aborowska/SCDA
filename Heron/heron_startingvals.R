# X1init=rep(1400,T)
# X1init[2:T] <- rpois((T-1),c(4000,y[2:(T-1)])*0.5)
# X2init=rep(1200,T)
# X2init[2:T] <- rbinom((T-1),X1init[1:(T-1)],0.9)
# X3init=rep(1000,T)
# X3init[2:T] <- rbinom((T-1),X2init[1:(T-1)],0.9)
# X4init=rep(900,T)
# X4init[2:T] <- rbinom((T-1),X3init[1:(T-1)],0.9)
# 
# inits <- function()(list(alpha=rep(0,4),beta=rep(0,4),alphal=0,betal=0,alpharho=0,tauy=1000,
#                          X1=X1init,X2=X2init,X3=X3init,X4=X4init))



alpha = c(-0.55, -0.1, 0.5, 1.1)
beta = c(0.02, -0.15, -0.15, -0.2)
alphal = 1.65
betal = -0.2
alpharho = 1.1
tauy = 0.1000

X1init= round(0.5*c(4000,y[-1]))
X2init= round(c(1500,y[-1]*2/7))
X3init= round(c(1000,y[-1]*(1.5)/7))
X4init= round(c(4000, y[-1]*4/7)) 


inits <- function()(list(alpha=alpha,beta=beta,alphal=alphal,betal=betal,alpharho=alpharho,tauy=tauy,
                         X1=X1init,X2=X2init,X3=X3init,X4=X4init))


# params <- c('alpha','alpharho','alphal', 'beta', 'betal', 'tauy', 'X1', 'X2', 'X3', 'X4')
params <- c('alpha','alpharho','alphal', 'beta', 'betal', 'tauy', 'X2', 'X4')
#params <- c('alpha','alpharho','alphal', 'beta', 'betal', 'X1', 'X2', 'X3', 'X4')