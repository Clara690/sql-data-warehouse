## What the project is about 

## How to run it on your machine
```text
docker compose -f mysql.yml up -d
```

In comaprison to SQL server, MySQL does not have the 3-tier object path, meaning that a schema is the same with a database. To bypass this, I created three different databases with a prefix *dw_*
to represent the different layers of the architecture. 