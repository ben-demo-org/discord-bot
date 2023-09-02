terraform {
  cloud {
    organization = "Corvius"

    workspaces {
      name = "discord-bot"
    }
  }
}