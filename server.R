library(shiny)
library(shinyFiles)
library(gplots)
library(grDevices)
library(SCPattern)

# Define server logic for slider examples
shinyServer(function(input, output, session) {
  volumes <- c('home'="~")
  shinyDirChoose(input, 'Outdir', roots=volumes, session=session, restrictions=system.file(package='base'))
  output$Dir <- renderPrint({parseDirPath(volumes, input$Outdir)})
  
  
  In <- reactive({
    print(input$Outdir)
    outdir <- paste0("~/",input$Outdir[[1]][[2]],"/")
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
    
	# Violin     
    if(List$ViolinTF){
        pdf(List$ViolinPlot, height=15,width=15)
		par(mfrow=c(4,4))
		for(i in 1:dim(Mat)[1]){
			if(List$logTF)VioFun(rownames(Mat)[i],log2(Mat+1),List$Cond, Dropout.remove=FALSE,ylab="log2(expression+1)")		
			if(!List$logTF)VioFun(rownames(Mat)[i],Mat,List$Cond, Dropout.remove=FALSE,ylab="Expression")			
		}
      dev.off()
	    print("Violin Plot...")
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
