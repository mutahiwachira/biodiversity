main_box <- function(title, ...){
  div(class = "panel panel-default",
    div(class = "panel-heading",title),
    div(class = "panel-body",...)    
  )
}