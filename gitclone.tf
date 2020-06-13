provider "aws" {
  region     = "ap-south-1"
  profile    = "task"
}


resource "null_resource" "git" {

 provisioner "local-exec" {
      command = "git clone https://github.com/ridham-ux/gitclonetf.git C:/Users/USER/Desktop/terra/gitimage"
}
provisioner "local-exec" {
      command = "cd .."
}
}