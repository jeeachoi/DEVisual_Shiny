library(shiny)
library(shinyFiles)
library(gplots)
library(ggplot2)
library(cowplot)
#library(grDevices)


# Define server logic for slider examples
shinyServer(function(input, output, session) {
  volumes <- c('home'="~")
  shinyDirChoose(input, 'Outdir', roots=volumes, session=session, restrictions=system.file(package='base'))
  output$Dir <- renderPrint({parseDirPath(volumes, input$Outdir)})
  
  
  In <- reactive({
    print(input$Outdir)
    #outdir <- paste0("~", input$Outdir[[1]][[2]], "/")
    outdir <- paste0("~",do.call("file.path",input$Outdir[[1]]),"/")
    print(outdir)
    
    the.file <- input$filename$name
    if(is.null(the.file))stop("Please upload data")
    Sep=strsplit(the.file,split="\\.")[[1]]
    if(Sep[length(Sep)]=="csv")a1=read.csv(input$filename$datapath,stringsAsFactors=F,header=TRUE, row.names=1)
    if(Sep[length(Sep)]!="csv")a1=read.table(input$filename$datapath,stringsAsFactors=F,header=TRUE, row.names=1)
    Data=data.matrix(a1)
    
    Group.file <- input$ConditionVector$name
    if(is.null(Group.file))GroupVIn = list(c1=rep(1,ncol(Data)))
    if(!is.null(Group.file)){
      Group.Sep=strsplit(Group.file,split="\\.")[[1]]
      if(Group.Sep[length(Group.Sep)]=="csv")GroupVIn=read.csv(input$ConditionVector$datapath,stringsAsFactors=F,header=F)
      if(Group.Sep[length(Group.Sep)]!="csv")GroupVIn=read.table(input$ConditionVector$datapath,stringsAsFactors=F,header=F, sep="\t")
    }
    GroupV=GroupVIn[[1]]
    if(length(GroupV)!=ncol(Data)) stop("length of the condition vector is not the same as number of cells!")
  
    Marker.file <- input$Markers$name
    if(is.null(Marker.file))MarkerVIn = list(c1=rownames(Data))
    if(!is.null(Marker.file)){
      Marker.Sep=strsplit(Marker.file,split="\\.")[[1]]
      if(Marker.Sep[length(Marker.Sep)]=="csv")MarkerVIn=read.csv(input$Markers$datapath,stringsAsFactors=F,header=F)
      if(Marker.Sep[length(Marker.Sep)]!="csv")MarkerVIn=read.table(input$Markers$datapath,stringsAsFactors=F,header=F, sep="\t")  
    }
    MarkerV=MarkerVIn[[1]]
    
    # Compose data frame
    #input$filename$name
    List <- list(
      Input=the.file,
      GroupFile=Group.file,
      MarkerFile=Marker.file,
      Cond=factor(GroupV, levels=unique(GroupV)),# follow the order they appeared
      Marker=factor(MarkerV, levels=unique(MarkerV)),# follow the order they appeared
	  
      HeatmapTF=ifelse(input$heatmap_button=="1",TRUE,FALSE), 
      ViolinTF=ifelse(input$violin_button=="1",TRUE,FALSE), 
    	  
      NormTF = ifelse(input$Norm_button=="1",TRUE,FALSE),
      OLTF = ifelse(input$OL_whether=="1",TRUE,FALSE),
	  clubyrowTF = ifelse(input$CluByRow_button=="1",TRUE,FALSE),
	  scaleTF = ifelse(input$scale_button=="1",TRUE,FALSE),
	  colorTF = ifelse(input$color_button=="1",TRUE,FALSE),
	  logTF=ifelse(input$log_whether=="1",TRUE,FALSE), 
    
	  Dir=outdir, 
      HeatmapPlot = paste0(outdir,input$HeatmapName,".pdf"),
      ViolinPlot = paste0(outdir,input$ViolinPlotName,".pdf")    
    )
	
    if(is.null(Marker.file)) print("Warning: All genes are used for ploting")
    
	# normalization     
    if(List$NormTF){
    Sizes <- MedianNorm(Data)
    if(is.na(Sizes[1])){
      Sizes <- MedianNorm(Data, alternative=TRUE)
      message("alternative normalization method is applied")
    }
    DataUse <- GetNormalizedMat(Data,Sizes)
    }    
    if(!List$NormTF){
      DataUse <- Data
    }
	
	# PushOL     
    if(List$OLTF){
		Q5 = apply(DataUse, 1, function(i) quantile(i, 0.05))
		Q95 = apply(DataUse, 1, function(i) quantile(i, 0.95))
		DataSc2 = DataUse
		for (i in 1:nrow(DataUse)) {
		    DataSc2[i, which(DataSc2[i, ] < Q5[i])] = Q5[i]
		    DataSc2[i, which(DataSc2[i, ] > Q95[i])] = Q95[i]
		}
		DataUse = DataSc2    
    }  
    if(length(which(!List$Marker %in% rownames(Data)))>0) {
      print("Warning: not all provided genes are in data matrix")
      List$Marker = intersect(rownames(Data),List$Marker)
    }
      
    if(List$colorTF) Col = colorRampPalette(c("green", "black", "red"))(156)
    if(!List$colorTF) Col = colorRampPalette(c("yellow", "black", "purple"))(156)

	Mat = DataUse[which(rownames(Data) %in% List$Marker),]
	
	# Heatmap     
    if(List$HeatmapTF){
		sc = "none"
		if(List$scaleTF) sc="row"
        pdf(List$HeatmapPlot, height=15,width=15)
		heatmap.2(Mat,trace="none",Rowv=List$clubyrowTF,Colv=FALSE,
		scale=sc,col=Col)
        dev.off()
	    print("Heatmap...")
    }
	
	ScdcViolin = function (y, cond, logT = TRUE, title.gene = "", 
	                       conditionLabels = NULL, axes.titles = TRUE) 
	{
	  require(ggplot2)
	  if (!is.factor(cond)) cond <- factor(cond, levels = unique(cond))

	  shps <- rep("a", length(cond))
	  
	  if (logT) y <- log2(y + 1)
	  
	  if (length(conditionLabels) == 2) {
	    condition = c()
	    condition[cond == levels(cond)[1]] <- conditionLabels[1]
	    condition[cond == levels(cond)[2]] <- conditionLabels[2]
	  }
	  if (length(conditionLabels) > 2) {
	    condition = c()
	    for(l in 1:length(conditionLabels)){
	      condition[cond ==levels(cond)[l]] <-conditionLabels[l]
	    }
	  }
	  if (axes.titles) {
	    xlabel <- ggplot2::element_text()
	    ylabel <- ggplot2::element_text()
	  } else {
	    xlabel <- ylabel <- ggplot2::element_blank()
	  }

	  daty <- data.frame(y, condition, shps)
	  g <- ggplot(daty, aes(factor(condition), y), aes(shape = shps))
	  g + geom_jitter(alpha = 0.5, color = "black", position = position_jitter(width = 0.15), 
	                  aes(shape = shps), 
	                  show.legend = FALSE) + geom_violin(data = daty[daty$y > 
	                                                                                      0, ], alpha = 0.5, aes(fill = factor(condition)), show.legend = FALSE, 
	                                                                        scale = "count") + ggtitle(paste0(title.gene)) + theme(plot.title = element_text(size = 20, 
	                                                                                                                                                         face = "bold", vjust = 2)) + labs(x = "Condition") + 
	    theme(axis.text.x = element_text(size = 14, vjust = 0.5), 
	          axis.text.y = element_text(size = 14, vjust = 0.5), 
	          axis.title.x = xlabel, axis.title.y = ylabel,  axis.line = element_line(colour = "black"),
	          panel.grid.major = element_blank(),
	          panel.grid.minor = element_blank(),
	          panel.border = element_blank() ) +
	    #draws x and y axis line
	    theme(axis.line = element_line(color = 'black'))
	}
	
	# Violin     
    if(List$ViolinTF){
      #pdf(List$ViolinPlot, height=15,width=15)
		  for(i in 1:dim(Mat)[1]){
			  save_plot(paste0(List$ViolinPlot,"_",rownames(Mat)[i],".png"),
			            ScdcViolin(Mat[i,]+1,List$Cond, logT=List$logTF,
			                       title.gene=rownames(Mat)[i],
			                       conditionLabels=c(unique(List$Cond)) ))		
		  }
      #dev.off()
	    print("Violin Plot")
    }
	DEG = rownames(Mat)
	List=c(List, list(Sig=DEG))  
	
})

 Act <- eventReactive(input$Submit,{
   In()})
 # Show the values using an HTML table
 output$print0 <- renderText({
   tmp <- Act()
   str(tmp)
   paste("output directory:", tmp$Dir)
 })
 
 output$tab <- renderDataTable({
   tmp <- Act()$Sig
   t1 <- tmp
   print("done")
   t1
 },options = list(lengthManu = c(4,4), pageLength = 20))
 
#  output$done <- renderText({"Done"})
})
