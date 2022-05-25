library(shinythemes)
shinyUI(fluidPage(theme = shinytheme("journal"),
  titlePanel("Twitter Affinity Score Explorer"),
  sidebarLayout(
    sidebarPanel(
      
      fileInput('affinity', 'Choose AFFINITY file to upload',
                accept = c(
                  'text/csv',
                  'text/comma-separated-values',
                  'text/tab-separated-values',
                  'text/plain',
                  '.csv',
                  '.tsv'
                )
      ),
      fileInput('matrix', 'Choose MATRIX file to upload',
                accept = c(
                  'text/csv',
                  'text/comma-separated-values',
                  'text/tab-separated-values',
                  'text/plain',
                  '.csv',
                  '.tsv'
                )
      ),
      sliderInput("maxPercentage", "Max. percentage", 50, 100, value = 99, step = 0.5),
      sliderInput("percentage", "Min. percentage", 0, 50, value = 20, step = 0.5),
      sliderInput("numberFactor", "Num. of components/clusters", 0, 10, value = 3, step = 1),
      sliderInput("minAffinity", "Min. affinity", 0, 100, value = 2, step = 1),
      sliderInput("treshold", "Min. treshold", 0, 20, value = 0, step = 1),
      sliderInput("minCorrelation", "Significant treshold", 0, 5, value = 0.3, step = 0.1),

  selectInput("binarydistance", "Methods for distance", 
        choices = list( 
"Jaccard index" = 1, 
"Simple matching coefﬁcient of Sokal & Michener " = 2,
"Sokal & Sneath" = 3,
"Rogers & Tanimoto" = 4,
"Dice" = 5,
"Hamann coefﬁcient" = 6,
"Ochiai" = 7,
"Sokal & Sneath" = 8,
"Phi of Pearson" = 9,
"S2 coefﬁcient of Gower & Legendre" = 10

), selected = 1),

  selectInput("hclustmethods", "Methods for hclust", 
        choices = list( 
"ward" = "ward", 
"single" = "single",
"complete" = "complete",
"average" = "average",
"mcquitty" = "mcquitty",
"median" = "median",
"centroid" = "centroid"
), selected = "ward"),

      tags$hr(),

      checkboxInput('header', 'Header', TRUE),
    
      tags$hr(),
      p('If you want a sample .csv or .tsv file to upload,',
        'you can first download the sample',
        a(href = 'mtcars.csv', 'mtcars.csv'), 'or',
        a(href = 'pressure.tsv', 'pressure.tsv'),
        'files, and then tresholdy uploading them.'
      )
    ),

    mainPanel(
      tabsetPanel(type = "tabs", 

        tabPanel("Overview",  tableOutput('contents'), dataTableOutput('tableAffinity')),
        tabPanel("HClust", imageOutput('dendrogram')),
        tabPanel("MDS", imageOutput('mds')),
        tabPanel("3DHclust", plotOutput('threed')),
        tabPanel("FA - Diagram", plotOutput('fact')),
        tabPanel("FA - Table", verbatimTextOutput('tableFact')),
        tabPanel("Network", plotOutput('graph')),
        tabPanel("Bayes LCA", plotOutput('BayesLoadCorelation'), dataTableOutput('tableBayesLoad'), verbatimTextOutput('tableBayes'))


  
      )
    )
  )
))