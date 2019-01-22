# Azure_Terraform

This is a very incomplete project that was made to brush up on my azure skills!

Currently, This will build out a complete VM envirnment along with it's networking.
Complete with custom images from packer, and custom nodes from a json config file ,using packer images to build from, boot scripts to run, and Terraform to deploy to them.

A single chef server is being built to apply recipes to the Nodes for config management.


The Goal is to run contianer orchastration usig Nomad running on Terraformed Nodes.
