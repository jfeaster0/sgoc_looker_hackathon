
project_name: "sgoc"

application: sgoc {
  label: "sgoc"
  #url: "https://localhost:8080/bundle.js"
  file: "bundle.js"
  entitlements: {
    core_api_methods: ["me"] #Add more entitlements here as you develop new functionality
  }
}


#Using create-looker-extension to create an extension template
