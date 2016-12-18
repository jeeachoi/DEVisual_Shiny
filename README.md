# DEVisual_Shiny

R/shiny app for DE visualization

## 1. Installation
This app requires the following packages: cowplot, ggplot2, gplots

To install the shiny and relevant packages, in R run:

> install.packages("shiny")

> install.packages("shinyFiles")

> install.packages("cowplot")

> install.packages("ggplot2")

> install.packages("gplots")

> install.packages("devtools")

### Run the app
To launch DEVisual Shiny GUI, in R run:

> library(shiny)

> library(shinyFiles)

> runGitHub('jeeachoi/DEVisual_Shiny')

![Screenshot](https://github.com/jeeachoi/DEVisual_Shiny/blob/master/figs/devisual.png)

## 2. Input files

The first input file should be a expression matrix. 
Rows are the genes and columns are the samples/cells.
Currently the program only takes csv files or tab delimited file.
The input file will be treated as a tab delimited file if the suffix is not '.csv'.

The second input file is a condition vector. The conditions could be biological condition, time points, spatial positions, etc. 
It could be csv or tab delimited file. The file should contain 1 column. The i th component represents the condition that cell i belongs to. The length of the condition vector should be the same as the number of cells in the first input file. Two or more conditions are expected. If condition input file is missing, all cells are considered to be from one condition.

The third input file is a DE gene list. It could be csv or tab delimited file. The file should contain
1 column, elements are the gene names.
If DE gene list input file is missing, all genes will considered as gene of interest. If a gene is not included in the expression matrix, the gene will be excluded for the visualization.

### Example files
Example input files for two conditions: **TwoCondDataMat.csv**, **TwoCond.csv**, and **DEmarker.csv** and example input files for multiple conditions: **MultiCondDataMat.csv**, **MultiCond.csv**, and **DEmarker.csv** could be found at https://github.com/jeeachoi/DEVisual_Shiny/tree/master/example_data   

## 3. Customize options

- Plot heatmap?
- Plot Violin plot for each DE gene?
- Need normalization? If Yes, median-by-ratio ormalization will be performed. If the input matrix is normalized (e.g. by median-by-ratio normalization or TMM), this option should be disabled. In addition, if the input expression matrix only contains a small set of genes, it is suggested to normalize using all genes first before taking the subset.
- Adjust outlier? If Yes, values <= 5 th quantile (>= 95 th quantile) will be pushed to qt1 th quantile (qt2 th quantile). 
- For Heatmap: Whether cluster by row
- For Heatmap: Whether scale the data within a row
- For Heatmap: Whether change the color theme. If No, Yellow/Purple theme will be used.
- For Violin Plot: Whether plot the expressions in log scale.
- Output directory, needs to be set. It will show error if not.
-	Output file name for the heatmap
-	Output file name for the Violin plots

## 4. Outputs
Two pdf files will be generated:
- PlotHeatmap.pdf: This file will be generated only when the user chooses to plot heatmap. In each plot, columns show samples and rows show gene. 
- PlotViolin.pdf: This file will be generated only when the user chooses to plot violin plot. In each plot, x-axis shows the condition and y-axis shows expression. 
 
## Note
User should select a "Output Folder" in the GUI



