# function that finds location of button on page
findButton <- function(browser_client, css_id){
  button <- tryCatch(
    browser_client$findElement("css selector", css_id),
    error = function(e){
      error_message <- browser_client$errorDetails()$message
      if(grepl(error_msg_overload, error_message)){
        browser_client$dismissAlert()
        findButton(browser_client, css_id)
      } else {
        if(grepl(error_msg_finish, error_message)){
          print("Everything loaded")
        } else {
          print(e)
        }
      }
    }
  )
}

# function that presses the button
pressButton <- function(button, browser_client, css_id){
  tryCatch(
    button$clickElement(),
    error = function(e){
      error_message <- button$errorDetails()$message
      if(grepl(error_msg_overload, error_message)){
        browser_client$dismissAlert()
        print("Alert dismissed, trying again")
        pressButton(button, browser_client, css_id)
      } else {
        if (grepl(error_msg_not_clickable, error_message)) {
          print("Couldn't click button, finding new position and trying again")
          # we're too fast, increment wait time to slow down
          wait_time <- wait_time + 1L
          pressButton(findButton(browser_client, css_id), browser_client, css_id)
        } else {
          if(grepl(error_msg_finish, error_message)){
            print("Everything loaded")
            return(TRUE)
          } else {
            print(e)
          }
        }
      }
    }
  )
}