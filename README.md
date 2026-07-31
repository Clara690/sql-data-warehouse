## What the project is about?
This project demonstrate how to build a dataware house with medallion architecture. 

In comaprison to SQL server, MySQL does not have the 3-tier object path, meaning that a schema is the same with a database. To bypass this, I created three different databases with a prefix *dw_*
to represent the different layers of the architecture. 

## How to run it on your machine
Setup MySQL server and phpadmin

```text
docker compose -f mysql.yml up -d
```

## Tips 💡
I got so tried of manual formatting my SQL code so I downloaded a [SQL formatter](https://github.com/darold/pgFormatter). 

Installation
```text
sudo apt install pgformatter
```

Usage
```text
pg_format -i {filename}
```
or remove the -i flag to have the output in terminal.