# DEVisual_Shiny

R/shiny app for DE visualization

## 1. Installation
This app requires the following packages:

To install the shiny packages, in R run:

> install.packages("shiny")

> install.packages("shinyFiles")

> install.packages("gplots")

> install.packages("grDevices")

> install.packages("devtools")

> library(devtools)

> install_github("lengning/SCPattern/package/SCPattern")

Or install locally.

### Run the app
To launch GUI, in R run: grDevices, gplots, SCPattern

> library(shiny)

> runGitHub('jeeachoi/DEVisual_Shiny')

![Screenshot](https://github.com/jeeachoi/DEVisual_Shiny/blob/master/figs/devisual.png)

## 2. Input files

The first input file should be the expression matrix. 
Rows are the genes and columns are the samples/cells.
Currently the program only takes csv files or tab delimited file.
The input file will be treated as a tab delimited file if the suffix is not '.csv'.

The second input file is the condition vector. The conditions could be biological condition, time points, spatial positions, etc. 
It could be csv or tab delimited file. The file should contain
1 column. The i th component represents the condition that cell i belongs to. The length of the condition vector should be the same as the number of cells in the first input file. Two or more conditions are expected. If condition input file is missing, all cells are considered to be from one condition.

The third input file is the DE gene list. It could be csv or tab delimited file. The file should contain
1 column, elements are the gene names.
If DE gene list input file is missing, all genes will considered as gene of interest. If a gene is not included in the expression matrix, the gene will be excluded for the visualization.

### Example files
Example input files for two conditions: **TwoCondMat.csv**, **TwoCond.csv**, and **DEmarker.csv** and example input files for multiple conditions: **MultiCondMat.csv**, **MultiCond.csv**, and **DEmarker.csv** could be found at https://github.com/jeeachoi/DEVisual_Shiny/tree/master/example_data   

## 3. Customize options

- Plot heatmap?
- Plot Violin plot for each DE gene?
- Need normalization? If Yes, normalization will be performed. If the input matrix is normalized (e.g. by median-by-ratio normalization or TMM), this option should be disabled. In addition, if the input expression matrix only contains a small set of genes, it is suggested to normalize using all genes first before taking the subset.
- Adjust outlier? If Yes, values <= 5 th quantile (>= 95 th quantile) will be pushed to qt1 th quantile (qt2 th quantile). 
- For Heatmap: Whether cluster by row
- For Heatmap: Whether scale the data within a row
- For Heatmap: Whether change the color theme. If No, Yellow/Purple theme will be used.
- For Violin Plot: Whether plot the expressions in log scale.
- Output directory, will be set as home directory (~/) if it is empty.
-	Output file name for the heatmap
-	Output file name for the Violin plots

## 4. Outputs
Two pdf files will be generated:
- PlotHeatmap.pdf: This file will be generated only when the user chooses to plot heatmap. In each plot, columns show samples and rows show gene. 
- PlotViolin.pdf: This file will be generated only when the user chooses to plot violin plot. In each plot, x-axis shows the condition and y-axis shows expression. 
 
## Note
The 'create new folder' button in the output folder selection pop-up is disfunctional right now




