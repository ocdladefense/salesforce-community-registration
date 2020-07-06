# Salesforce Custom Registration
Lightning components, controllers and classes to process Salesforce Community registrations.

## Package structure
### Package 1
Site Registration - Main registration component and aura controller.
### Package 2
Lightning Library - Supplementary components to facilitate registration, especially an SObject Lookup component.
### Package 3
Registration Helpers - Classes to process custom before and after registration actions.  Examples of before and after actions include specifying an AccountId to associate with a newly created account or updating the created Contact with ad-hoc data (Title, etc.) after the registration is processed.


## SFDX Commands 


### Package Creation
```
sfdx force:package:create --name "Site Registration" --path sfdx-source/SiteRegistration --packagetype Unlocked --description "Customized site registration."
```
```sfdx force:package:create --name "Lightning Library" --path sfdx-source/LightningLibrary --packagetype Unlocked --description "Lightning components."```
```
sfdx force:package:create --name "Registration Helpers" --path sfdx-source/RegistrationHelpers --packagetype Unlocked --description "Registration Helpers."
```

### Versions
```
sfdx force:package:version:create --package "Site Registration" --wait 20 --installationkeybypass --codecoverage --versionnumber "0.1.3.0"
```
```
sfdx force:package:version:create --package "Lightning Library" --wait 20 --installationkeybypass --codecoverage --versionnumber "0.1.3.0"
```
```
sfdx force:package:version:create --package "Registration Helpers" --wait 20 --installationkeybypass --codecoverage --versionnumber "0.1.3.0"
```

### Release
```
sfdx force:package:version:promote --package 04t3h000003Rwk2AAC
```

### Installation
```
sfdx force:package:install --package 04t3h000003Rwk2AAC -u jbernal.web.dev@gmail.com.fdlidev --wait 10 --publishwait 10 -a package 
```

## Common errors
```
Error  sfdx-source/SiteRegistration/aura/Register/Register.cmp  You can't remove design attributes 'updateContactOnMatchingEmail' when the component implements a Lightning Page interface.
ERROR running force:source:push:  Push failed.
```
