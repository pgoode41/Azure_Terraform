resource "azurerm_virtual_machine" "fry" {
    name                  = "fry"
    location              = "eastus"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
    network_interface_ids = ["${azurerm_network_interface.frynic.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "frydisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        id = "/subscriptions/e1104a5e-a351-4717-8fb8-01a888aa18af/resourceGroups/myResourceGroup/providers/Microsoft.Compute/images/PackerNodeImage"
    }

    os_profile {
        computer_name  = "myvm"
        admin_username = "azureuser"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDhoAirP6nTF2i0QtvStEFUEb1EUpfXW7CDXp5Ftpb0ZggZulOSkn0aba+c1SmR8Y+KUqBO4TK7DnoQ6GL59H0IyF0KtVkOHa5q08YaqyLDYLaKOdQmaIuG+15DISH89wDftyZYLTTi9K1oVnpUO6NqvpJRXpw5HE2gFHnTVgukU9SibaMHPjzVBO90NDN5DJbKrf+X2CIbewjIEGClt5ySfRZKaaYtYAakpiZ4c/TevghelQNBqmJjfgomKqlv5+HYr/bd7bEIvbiJr7sT6biOAHLRGGFtp1IX9jHxWuY7XY0LWCCX6RSp0Yhh0Ph7SWYvISz7P6tU3VH+lFXixUahkbSymubrB6qXzFzylQkDMqEh8xxSCPXE8qSsksuzgFzkd1V5rBB9DQUv7LwoaF7J+g8kIjt+9hlTbxlRlhe4zD/HsydBIyLzsam3SVbCbioPqkx11wXRnTOGJURndY0L6KgD0Diw6XU5LLZsIUgqT/s6FCBeAXhEagmVifIr1pWIBMYrYdb/ySomoIwI9lxaxghZtmNDbAxXUaWVkaG31bND2gSBV9MnRC0FEyeshI6tloEJcQMKW0BhOb/anL+OKTEX9JF4jiAibUKWWIYsMiywz4QBTp/WDJZL2aN01biGMqF6oMfnhVNeolo4nnRAfzDuBcrLfDPZnPVLzlbMPQ== pgoode41@gmail.com"
        }
    }

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_interface" "frynic" {
    name                = "frynic"
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.fryPublicIP.id}"
    }

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_public_ip" "fryPublicIP" {
    name                         = "fryPublicIP"
    location                     = "eastus"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "Terraform Demo"
    }
}