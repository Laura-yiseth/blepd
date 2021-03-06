#'
#' @title evalTerminal
#'
#' @description The function calculates whether a change in the terminal branch length generates a change in the area selected; and when applies, the terminal branch length value for that change.  
#' 
#' @return Returns four fields, and depending on the results -whether there is no-change/change in area as we change the terminal branch length-, the function returns the maxPD difference for the upper limit, or 0.0 for the lower limit, the best Initial Area, a dummy value of "*" to indicate there is no change in area and the actual (initial) branch length; or, when there is a change in area selected, the function returns the branch length of the change, the best Initial Area, the area selected, and the actual (initial) branch length.
#'
#' @param tree is a single tree with T terminals, an APER phylo object.
#' 
#' @param distribution is a labeled matrix object, with the distribution of T terminals (rows) in A areas (columns).
#' 
#' @param tipToEval is the label of the terminal to evaluate.
#' 
#' @param approach is the type of limit to evaluate, "upper": from the actual length to maxVal, or "lower": from the actual length to 0. 
#' 
#' @param maxMultiplier is the value to multiply the sum of the PD values. This value will be the upper limit to evaluate. 
#' 
#' @param root is use.root in PD function. 
#' 
#' 
#' @examples
#' library(blepd)
#' data(tree)
#' data(distribution)
#' evalTerminal(tree = tree , distribution = distribution , 
#' tipToEval = "t1" ,  approach = "lower" , root = FALSE)
#'
#'
#'@author Miranda-Esquivel Daniel R.
#'
#'

evalTerminal <- function(tree = tree , distribution = distribution , 
                         tipToEval = "taxB" , approach = "lower" , 
                         root = FALSE ,
                         index = "PD",
                         maxMultiplier = 1.01 ){

if(any(apply(distribution,2,sum)==1)){root = TRUE}

##if(debugDRME){cat("\n inicio en terminal:",tipToEval,":",approach,"\n")}

## potential errors

        .checkInput(tree = tree , distribution = distribution)

        numberTipToEval <- which(tree$tip.label %in% tipToEval) 
        
#~         print(numberTipToEval)
#~         print(tree$tip.label[numberTipToEval])
        
        
        if (is.na(numberTipToEval)){
			stop("Check names in tree / distribution. Mind the closing door")
			}

        if(!all(colnames(distribution) %in% tree$tip.label)){
			stop("Check names in tree / distribution. Mind the closing door")
			}


        
## initial stuff

        initialPD <- PDindex( tree = tree, distribution = distribution, root = root, index = index )
        
#~         initialPD[is.na(initialPD)] <-   0.0
        
                
        bestInitialArea <- c(.bestVal(distribution,initialPD))
        
        
        #print(bestInitialArea)
                
        
        initialLength <- round(tree$edge.length[which(.createTable(tree)[,2] %in% numberTipToEval)],4)
       
       #print(initialLength)
               
## initial test of branch length equal to zero
        
               newTree <- tree
    
        if (tolower(approach) %in% c("lower") ){
			
            newTree$edge.length[which(.createTable(tree)[,2] %in% numberTipToEval)] <-  0
            
            maxPD <- 0 ##+ 1
            
			}
			
                
        if (tolower(approach) %in% c("upper") ){
			
			maxVal <- maxMultiplier * round(sum(tree$edge.length),6)
			
			newTree$edge.length[which(.createTable(tree)[,2] %in% numberTipToEval)] <-  maxVal
                        
            maxPD <- max(initialPD) - min(initialPD)
            	
			}
        
            
                
        modifiedPD <- PDindex(tree = newTree, distribution = distribution, root = root, index = index )
          
        bestModifiedArea <-  c(.bestVal(distribution,modifiedPD))
        
              
        if(all(bestInitialArea %in% bestModifiedArea) &
           all(bestModifiedArea %in% bestInitialArea)){
			   
			if(approach == "upper"){
			   promedio <- maxVal
			   }else{
				promedio <- 0.0
				}   
            
            ans <- list (maxPD            =   maxPD , 
                         areas            =   rownames(distribution),
                         terminals        =   colnames(distribution),
                         bestInitialArea  =   bestInitialArea, 
                         bestModifiedArea =   bestModifiedArea,
                         modifiedPD       =   modifiedPD,
                         initialPD        =   initialPD,
                         initialLength    =   initialLength,
                         root             =   root,
                         tipToEval        =   tipToEval  , 
                         approach         =   approach  , 
                         index            =   index,
                         delta            =   promedio
                         )
            
            print("no effect of 0 or Max branch length")
                                   
            return(ans)
            
              break("got it")
        }
                        
        ## end of est branch of zero length or max       
    
        
        ## let's continue
        
        ## create a divide and conquer loop 
        
    if (tolower(approach) == "lower"){
    
        ValorPrevio    <-  9999999999
                
        initial        <-  0.0
        
        final          <- initialLength
        }


    if (tolower(approach) == "upper"){
    
        ValorPrevio <- 9999999999
                
        initial  <- initialLength+0.00001
        
        final <- maxVal
        }


    repeat{
		
		
            promedio <- mean(c(final,initial))
                  
            newTree$edge.length[which(.createTable(tree)[,2] %in% numberTipToEval)] <-  promedio
            
            reCalculatedPD  <- PDindex(tree = newTree, distribution = distribution, root = root, index = index )
            
            bestModifiedArea <-  c(.bestVal(distribution,reCalculatedPD))
        
 
##if(debugDRME & fineDebug){cat((promedio != ValorPrevio),"|",ValorPrevio,"==",promedio,"|  init",bestInitialArea,"modif",bestModifiedArea,"||",initial,"---",final,"| val PD:",paste(reCalculatedPD,sep="__"),"\n")}
     
    if(round(promedio,6) != round(ValorPrevio,6)) { 
        
        ValorPrevio <- promedio
        
     if((all(bestInitialArea %in% bestModifiedArea)) &
        (all(bestModifiedArea  %in%  bestInitialArea))){
   
        if (tolower(approach) == "lower"){
			final <- promedio
			}
      
        if (tolower(approach) == "upper"){
			inicial <- promedio            
            }
        
        }else{
              
        if (tolower(approach) == "lower"){
			initial <- promedio
			}

        if (tolower(approach) == "upper"){
			final <- promedio
			}
            
            }
    
        }else{
         
        if (tolower(approach) == "lower"){
            
            promedio <- promedio - 0.0001
            
             newTree$edge.length[which(.createTable(tree)[,2] %in% numberTipToEval)] <-  promedio
            
            reCalculatedPD  <- PDindex(tree = newTree, distribution = distribution, root = root, index = index )
            
            bestModifiedArea <-  c(.bestVal(distribution,reCalculatedPD))
            
            
            ans <- list (maxPD            =   maxPD , 
                         delta            =   round(promedio,4) ,
                         areas            =   rownames(distribution),
                         terminals        =   colnames(distribution),
                         bestInitialArea  =   bestInitialArea, 
                         bestModifiedArea =   bestModifiedArea,
                         modifiedPD       =   modifiedPD,
                         initialPD        =   initialPD,
                         initialLength    =   initialLength,
                         root             =   root,
                         tipToEval        =   tipToEval  , 
                         approach         =   approach  , 
                         index            =   index 
                         )
            
            
            #!#names(resp) <- c("branchLengthChange","bestInitialArea","bestModifiedArea","initialLength")
            
            return(ans)
            
            
            break("got it")
        }
        
        if ((tolower(approach) == "upper")  &
        !all(bestInitialArea %in% bestModifiedArea)){
            
            promedio <- promedio + 0.0001
            
      ##      resp <- c(round(promedio,4), bestInitialArea, bestModifiedArea, initialLength)
      
            ans <- list (maxPD            =   maxPD , 
                         average          =   round(promedio,4) ,
                         areas            =   rownames(distribution),
                         terminals        =   colnames(distribution),
                         bestInitialArea  =   bestInitialArea, 
                         bestModifiedArea =   bestModifiedArea,
                         modifiedPD       =   modifiedPD,
                         initialPD        =   initialPD,
                         initialLength    =   initialLength,
                         root             =   root,
                         tipToEval        =   tipToEval  , 
                         approach         =   approach  , 
                         index            =   index 
                         )
      
            
            #!#names(resp) <- c("branchLengthChange","bestInitialArea","bestModifiedArea","initialLength")
            
            return(ans)
            
            break("got it")
            
        }else{
			initial <- promedio
			}
                      
    }
    
    } 
    ## end  repeat
            
    }
        
## end best
    
