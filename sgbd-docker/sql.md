docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Mypassw0rd123!" `
-p 1422:1433 --name sqlserverBI `
-v sqlserver-volume:/var/opt/mssql `
-d mcr.microsoft.com/mssql/server:2022-latest