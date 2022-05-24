library(ade4)
library(vegan)
library(vegan3d)
library(polycor)
library("psych")
library("BayesLCA")
library("igraph")

# By default, the file size limit is 5MB. It can be changed by
# setting this option. Here we'll raise limit to 9MB.
options(shiny.maxRequestSize = 30*1024^2)
options(shiny.trace=TRUE)

shinyServer(function(input, output) {

  

iniTable <- function(affinityFile, matrixFile, minProcent=3, minAffinity=0.8, treshold=0, maxProcent=100) {
 
  tblSourceMatrix <- read.csv(matrixFile, header=TRUE, check.names=FALSE, sep=";")
  tblaffinity <- read.csv(affinityFile, sep=";")

    tblaffinity$username <- as.character(tblaffinity$username)
                tblaffinity <- subset(tblaffinity, percentage >= minProcent & percentage <= maxProcent &  affinity > minAffinity)
              
                tblaffinity$id <- as.character(tblaffinity$username)
                vybranaName <- as.vector(tblaffinity$username)
                vybranaID <- as.vector(tblaffinity$id)


             #              tblSourceMatrix$userId <- as.character(tblSourceMatrix$username)
             #              rownames <- tblSourceMatrix$userId
             #              tblSourceMatrix <- subset(tblSourceMatrix, select = -userId)
                
             #              colnames.df <- data.frame(colnames(tblSourceMatrix))
                
            #               colnames(colnames.df) <- c("id")    
              #             colnames.df.all <- merge(colnames.df, tblaffinity, by="id")

              #  tblSourceMatrix <- subset(tblSourceMatrix, select = c(vybranaID))
#                       tblSourceMatrix <- subset(tblSourceMatrix, username %in%  c(vybranaID))
            #    colnames(tblSourceMatrix) <- as.vector(colnames.df.all$name)


            #             tblSourceMatrix <- t(tblSourceMatrix)
            #             tblSourceMatrix <- as.data.frame(tblSourceMatrix)
            #             tblSourceMatrix$id <- rownames(tblSourceMatrix)
            #             tblSourceMatrix <- merge(tblSourceMatrix, tblaffinity, by="id")
            #            rownames(tblSourceMatrix) <- tblSourceMatrix$name

 
tblSourceMatrix <- subset(tblSourceMatrix, username %in% vybranaName)

rownames(tblSourceMatrix) <- tblSourceMatrix$username
tblSourceMatrix$username <- NULL

            tblSourceMatrix$id <- NULL
            tblSourceMatrix$username <- NULL 
            tblSourceMatrix$likers <- NULL
            tblSourceMatrix$normal <- NULL
            tblSourceMatrix$percentage <- NULL
            tblSourceMatrix$affinity  <- NULL
            tblSourceMatrix$distance <- NULL
            tblSourceMatrix$name <- NULL




    tbla <- tblSourceMatrix
    tbla <- tbla[,colSums(tbla) > treshold]
    tblSourceMatrix <- tbla

    tblSourceMatrix <- tblSourceMatrix[,colSums(tblSourceMatrix) > 0]
    
    mydata <- as.data.frame((tblSourceMatrix))
    mydata

}


output$dendrogram <- renderImage({
    affinity <- input$affinity
    matrix <- input$matrix
    if (is.null(affinity) || (is.null(matrix) )){ return(NULL) }
 
    width  <- 1024
    height <- 768

    outfile <- tempfile(fileext = ".png")
      
      mydata <- iniTable(affinity$datapath, matrix$datapath, input$percentage, input$minAffinity,input$treshold, input$maxPercentage)

      d <- dist.binary(mydata, method = 1)
      fit <- hclust(d)   
   

    png(outfile, width=width, height=height)
          plot(fit)

    dev.off()
    
    list(src = outfile,
         contentType = "image/png",
         width = width,
         height = height,
         alt = "This is alternate text")

  }, deleteFile = TRUE)


output$mds <- renderImage({
    affinity <- input$affinity
    matrix <- input$matrix
    if (is.null(affinity) || (is.null(matrix) )){ return(NULL) }


    width  <- 1024
    height <- 768

    outfile <- tempfile(fileext = ".png")
      
      mydata <- iniTable(affinity$datapath, matrix$datapath, input$percentage, input$minAffinity,input$treshold, input$maxPercentage)

    d <- dist.binary(mydata, method = 1)
    fit <- cmdscale(d,eig=TRUE, k=2) # k is the number of dim
    x <- fit$points[,1]
    y <- fit$points[,2]
    
    png(outfile, width=width, height=height)
          plot(x, y, xlab="Coordinate 1", ylab="Coordinate 2", main="Metric  MDS",  type="n")
          text(x, y, labels = row.names(mydata), cex=1.2)


    dev.off()
    
    list(src = outfile,
         contentType = "image/png",
         width = width,
         height = height,
         alt = "This is alternate text")

  }, deleteFile = TRUE)

output$threed <- renderImage({
    affinity <- input$affinity
    matrix <- input$matrix
    if (is.null(affinity) || (is.null(matrix) )){ return(NULL) }


    width  <- 1024
    height <- 768

    outfile <- tempfile(fileext = ".png")
      
      mydata <- iniTable(affinity$datapath, matrix$datapath, input$percentage, input$minAffinity,input$treshold, input$maxPercentage)

# 3d

    d <- vegdist(mydata)
    m <- metaMDS(d)
    cl <- hclust(d)
    
    png(outfile, width=width, height=height)
      orditree3d(m, cl, pch=16, col=cutree(cl, input$numberFactor), type = "t")
    dev.off()
    
    list(src = outfile,
         contentType = "image/png",
         width = width,
         height = height,
         alt = "This is alternate text")

  }, deleteFile = TRUE)


output$graph<- renderImage({
    affinity <- input$affinity
    matrix <- input$matrix
    if (is.null(affinity) || (is.null(matrix) )){ return(NULL) }


    width  <- 1024
    height <- 768

    outfile <- tempfile(fileext = ".png")
      
      mydata <- iniTable(affinity$datapath, matrix$datapath, input$percentage, input$minAffinity,input$treshold, input$maxPercentage)
      het.mat <- hetcor(t(mydata))$cor
      
      b <-  hetcor(t(mydata))$cor

      tblGraph <- b

      # vyber jen vazby, které mají minimální hodnotu thresholdu. Nejmenší doporučovaná korelace je 0.4, ideální je 0.7
      threshold <- input$minCorrelation
      tblGraph[tblGraph > threshold] <-  1
      tblGraph[tblGraph <= threshold] <- 0

      g  <- graph.adjacency(tblGraph,mode="undirected")
      g <- simplify(g)


    png(outfile, width=width, height=height)
           plot(g, vertex.size=10, vertex.label=V(g)$label, 
           layout=layout.fruchterman.reingold,  edge.arrow.size=0.2)
    dev.off()
    
    list(src = outfile,
         contentType = "image/png",
         width = width,
         height = height,
         alt = "This is alternate text")

  }, deleteFile = TRUE)


output$fact <- renderImage({
    affinity <- input$affinity
    matrix <- input$matrix
    if (is.null(affinity) || (is.null(matrix) )){ return(NULL) }


    width  <- 1024
    height <- 768

    outfile <- tempfile(fileext = ".png")
      
      mydata <- iniTable(affinity$datapath, matrix$datapath, input$percentage, input$minAffinity,input$treshold, input$maxPercentage)
      het.mat <- hetcor(t(mydata))$cor
      fit <- principal(het.mat, input$numberFactor)


    
    png(outfile, width=width, height=height)
      fa.diagram(fit)
    dev.off()
    
    list(src = outfile,
         contentType = "image/png",
         width = width,
         height = height,
         alt = "This is alternate text")

  }, deleteFile = TRUE)



output$tableFact <- renderPrint({

       affinity <- input$affinity
    matrix <- input$matrix
    if (is.null(affinity) || (is.null(matrix) )){ return(NULL) }


    width  <- 1024
    height <- 768

    outfile <- tempfile(fileext = ".png")
      
      mydata <- iniTable(affinity$datapath, matrix$datapath, input$percentage, input$minAffinity,input$treshold, input$maxPercentage)
      het.mat <- hetcor(t(mydata))$cor
      fit <- principal(het.mat, input$numberFactor)
fit
   
  })

#### bayesLCA
output$tableBayes <- renderPrint({

    affinity <- input$affinity
    matrix <- input$matrix
    if (is.null(affinity) || (is.null(matrix) )){ return(NULL) }


  mydata <- iniTable(affinity$datapath, matrix$datapath, input$percentage, input$minAffinity,input$treshold, input$maxPercentage)
  withProgress(message = 'bLCA value: calculation in progress.',
                 detail = 'This may take a while...', value = 0, { 
      mydata <- iniTable(affinity$datapath, matrix$datapath, input$percentage, input$minAffinity,input$treshold, input$maxPercentage)
      fitBayes <- blca(t(mydata), input$numberFactor, method = "em")
      fitBayes
    })
  })

output$tableBayesLoad<- renderDataTable({
withProgress(message = 'bLCA loadings: calculation in progress.',
                 detail = 'This may take a while...', value = 0, { 


    affinity <- input$affinity
    matrix <- input$matrix
    if (is.null(affinity) || (is.null(matrix) )){ return(NULL) }

      mydata <- iniTable(affinity$datapath, matrix$datapath, input$percentage, input$minAffinity,input$treshold, input$maxPercentage)
      fitBayes <- blca(t(mydata), input$numberFactor, method = "em")
      results <- t(as.matrix(fitBayes$itemprob))
      results <- data.frame(results)
      results <- round(results,3)
      results$name <- rownames(results)
    })
      results
  }, escape = FALSE)

output$BayesLoadCorelation <- renderPlot({
withProgress(message = 'bLCA correlation: calculation in progress.',
                 detail = 'This may take a while...', value = 0, { 

      affinity <- input$affinity
    matrix <- input$matrix
    if (is.null(affinity) || (is.null(matrix) )){ return(NULL) }

  mydata <- iniTable(affinity$datapath, matrix$datapath, input$percentage, input$minAffinity,input$treshold, input$maxPercentage)
      fitBayes <- blca(t(mydata), input$numberFactor, method = "em")
      results <- t(as.matrix(fitBayes$itemprob))
      results <- data.frame(results)
      a <- cor(results)
      d <- dist(a , method = "euclidean") # distance matrix
      fit <- hclust(d, method="ward") 
    })
      plot(fit)
  })



#### tabulka Affinit
  output$tableAffinity <- renderDataTable({
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.
    
    affinity <- input$affinity
    
      if (is.null(affinity))
        return(NULL)
    
    aff <- read.csv(affinity$datapath, header = input$header,
             sep=";")
    

    subklastr <- subset(aff, affinity>input$minAffinity &  percentage > input$percentage & percentage<=input$maxPercentage)
    subklastr$id <- NULL
    subklastr$normal <- NULL
    # subklastr$username <- NULL
    soubor <- subklastr[order(subklastr$affinity,decreasing=FALSE),]
soubor
  
  })


  output$contents <- renderTable({

    
    affinity <- input$affinity
    matrix <- input$matrix
    if (is.null(affinity) || (is.null(matrix) )){
      return(NULL)
    
      }

      tmp <- iniTable(affinity$datapath, matrix$datapath, input$percentage, input$minAffinity, input$treshold, input$maxPercentage)
      restcount <- ncol(tmp)
      tblSourceMatrix.org <- read.csv(matrix$datapath, header=TRUE, check.names=FALSE, sep=";")

      ratio <- restcount/nrow(tblSourceMatrix.org)
  data.frame(
      Name = c("Původní počet", 
               "Zbylý počet", "Ratio"),

      Value = as.character(c(nrow(tblSourceMatrix.org), restcount, ratio)), 
      stringsAsFactors=FALSE)

   })



})