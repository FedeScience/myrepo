#@ https://gist.github.com/rain1024/98dd5e2c6c8c28f9ea9d

require(rmarkdown)
my_text <- readLines("~/Documenti/CoverLetter.txt") 
cat(my_text, sep="  \n", file = "my_text.Rmd")
render("my_text.Rmd", pdf_document())
file.remove("my_text.Rmd") #cleanup
