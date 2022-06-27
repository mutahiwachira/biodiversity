main_box <- function(title, ...){
  div(class = "panel",
    div(class = "panel-heading", title, 
        style = "color: #000;
                 background-color: #61c336;
                 border-color: #61c336;
                border: 3px"),
    div(class = "panel-body",...)    
  )
}