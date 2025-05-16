# IT-driftsmiljø
## Beskrivelse
Repo for all koden som blir produsert under bacheloroppgaven vår

## Forhåndskrav
- Azure abonnement
- Github bruker


## Førstegangsoppsett
De følgende stegene utføres kun første gang driftsmiljøet skal tas i bruk.
### Steg 1: Lag service principle i Azure
Dette steget oppretter en identitet i Azure som brukes til autentisering når du bygger infrastruktur med terraform.



1. Opprett service principle. Denne kommandoen kjøres i Azure cli som du finner i Azure portalen, til høyre for søkebaren.
```
az ad sp create-for-rbac --scopes /subscriptions/<SUBSCRIPTION_ID> --role contributor
```
Ta vare på objektet som kommer i retur, da du ikke får hentet dette ut igjen.

2. Tildel roller: 
   
- "Key Vault Administrator":
```
az role assignment create \
  --assignee <APPID> \
  --role "Key Vault Administrator" \
  --scope /subscriptions/<SUBSCRIPTION_ID>
```

- "Key Vault Data Access Administrator"
```
az role assignment create \
  --assignee <APPID> \
  --role "Key Vault Data Access Administrator" \
  --scope /subscriptions/<SUBSCRIPTION_ID>

```




### Steg 2: Sett opp repo

1. Fork repoet https://github.com/Bachelorgruppe117-NTNU-Gjovik/IT-driftsmiljo


2. Opprett secrets i Github repo

Workflowsene i løsningen er avhengig av at visse verdier lagres som Secrets. Disse kan opprettes i Github grensesnittet, under "settings" i repoet. Opprett følgende secrets med tilhørende verdier:

- ARM_CLIENT_ID      
- ARM_CLIENT_SECRET
- ARM_SUBSCRIPTION_ID
- ARM_TENANT_ID
- REG_TOKEN       //token til Github Container Registry
- REG_UNAME       //brukernavn til Github Container Registry
- ALLOWED_IP_RANGE   //offentlig IP-adresse i CIDR format

Merk at ALLOWED_IP_RANGE brukes til studentoppgaver som skal konfigureres med begrenset nettverkstilgang. Slike studentoppgaver vil kun være tilgjengelige fra hoster innenfor nettverket som ligger i ALLOWED_IP_RANGE.

3. Opprett Github Container Registry


### Steg 3: Logg inn med service principle
Hvis du allerede har installert Azure CLIet kan du hoppe over punkt nr. 1.

1. [Installer](https://learn.microsoft.com/nb-no/cli/azure/install-azure-cli) Azure CLI
2. Logg inn med service principle:
   ```
   az login --service-principal --username <appId> --password <password> --tenant <tenant>
   ```
3. Klon repo

### Steg 4: Sett inn terraform.tfvars.json

1. Plasser terraform.tfvars.json i /IT-driftsmiljo/terraform/infrastruktur

2. Sett inn verdier for følgende variabler:
   - "alert_name"
   - "email_address"
   - "sms_number"


### Steg 5: Last ned Terraform
Om du allerede har Terraform installert på maskinen, kan du hoppe over dette steget. Her er en full [guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) til å installere terraform.



### Steg 6: Sett variabler:
   
   Sett følgende miljøvariabler i terminalen:
   
   ```
   ARM_CLIENT_ID
   ARM_CLIENT_SECRET
   ARM_TENANT_ID 
   ARM_SUBSCRIPTION_ID

   TF_VAR_reguname   //brukernavn til Github Container Registry
   TF_VAR_regtoken   //token til Gtihub Container Registry
   TF_VAR_rootPath   //full path til mappen IT-dritfsmiljø (bruk '/' til å skille mellom mappene, f.eks. "C:/Users/user1/IT-driftsmiljo")
   ```

### Steg 7: Apply backend
Disse stegene kan gjøres både i en linux terminal og Powershell.

1. Naviger til /terraform/backend.
2. Gå til main.tf og sett inn subscription ID i "provider "azurerm"" blokken.
3. Initialiser terraform:
   ```bash
   terraform init
   ```
4. Lag plan filen
   ```bash
   terraform plan -out="main.tfplan"
   ```
5. Bygg konfigurasjon
   ```bash
   terraform apply "main.tfplan
   ```
### Steg 8: Apply infrastruktur

1. Åpne /terraform/infrastruktur/main.tf.
2. I blokken "backend "azurerm"", sett "storage_account_name" til navnet på backend storage accounten. Dette navnet finner du i azure under resource groups -> rg-backend.
3. Naviger til /terraform/infrastruktur.
4. Repeter punkt nr. 3, 4 og 5 fra forrige steg.

## Legge inn ny studentoppgave
### Steg 1: Laste ned og sjekke filer
Last ned git repo eller finn mappen som har blitt levert av studentene. Sjekk at mappen har en Dockerfil og en databasemappe i root dersom studentoppgaven trenger en database. Databasemappen kan være tom, men den skal bare være der for å vise at studentoppgaven inneholder en database. Legg studentoppgave inn i /studentOppgaver/ mappen. Husk å slette eventuelle git filer i studentoppgavemappen, f.eks. .git.
```plaintext
<studentoppgavenavn>/
├── README.md            # Dokumentasjon og installasjonsinstrukser
├── database/            # Databasefiler
│   ├── *DDL*.txt        # Database skjema (CREATE, ALTER, osv.)
│   └── *DML*.txt        # Database data (INSERT, UPDATE, osv.)
├── Dockerfile           # Fil for bygging av Docker image
└── ...                  # Andre filer for studentoppgaven
```

### Steg 2: Opprett rolle

Åpne Azure ClI som du finner i Azure portalen. Kjør følgende kommando:

```
az role assignment create \
  --assignee <APPID> \
  --role "Storage Blob Contributor" \
  --scope "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<rg-variablestorage>/providers/Microsoft.Storage/storageAccounts/<envstoragegjovik246>"
```

### Steg 2: Laste opp filer til github
For å legge inn en ny studentoppgave i driftsmiljøet benyttes Github workflows. Etter at studentoppgaven er plassert i /studentOppgaver/, kjøres /terraform/infrastruktur/scripts/newApp.py. Dette scriptet pusher den nye studentoppgaven til remote repoet og aktiverer workflowsene.
<br> 
```bash
python newApp.py <studentoppgavenavn> -a <public/private>
```
Studentoppgavenavn er mappenavnet til studentoppgaven. 

Dette aktiverer først workflowen Docker-build.yml. Den lager et nytt Docker image og lagrer det i Githubs container register tilknyttet brukeren repoet tilhører. Deretter aktiveres buildTerraform.yml som legger til nye verdier i Terraform og applyer den nye konfigurasjonen.

For å se utførelse av workflows, gå til Actions fanen på repoets Github side.

### Steg 3: Initiere database
Dette seteget utføres kun hvis studentoppgaven trenger tilgang til en database.

1. Legg DDL og DML filer inn i database mappen til den aktuelle studentoppgaven:
```plaintext
<studentoppgavenavn>/
├── database/
│   ├── *DDL*.txt
│   └── *DML*.txt
```
2. Kjør scriptet "jmphost.py". Merk at "APPID" og "PASSWORD" tilhører service principle som ble opprettet tidligere.
```bash
python jmphost.py <studentoppgavenavn> <database-adminbrukernavn> <APPID> <PASSWORD> <TENANTID> init
```

3. Restart container appen. Dette kan gjøres i Azure portalen.

## Fjerne studentoppgave
Fjerning av studentoppgave fra dritfsmiljøet skjer via workflowsene remove.yml og buildTerraform.yml. For å aktivere disse må repoet pushes til remote med commit meldingen:

```
fjern studentoppgave <studentoppgavenavn>
```
De aktiverte workflowsene vil fjerne studentoppgavens Docker image fra Github, redigere Terraform koden og kjøre en ny Terraform apply.



## License

[MIT](https://choosealicense.com/licenses/mit/)
