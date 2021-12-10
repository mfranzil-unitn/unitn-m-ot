# cctf-ss
Secure server repo

ssh -L 7777:server.cctf-ss.offtech:80 deter

# TO DO

## BLUE TEAM

DA FARE

Programma di monitoring per rilevare eventualia attacchi. -> FATTO

Patchare le vulnerabilità e mantenere una lista delle modifiche fatte.

Sviluppare sistemi di protezione lato gateway - server.

Proteggere da eventuali data breach (controllo accessi?).

Fornire il log nel folder /tmp/request in modalità append.only.

Avere un log write-only dove si segnano tutte le transazioni identificate univocamente corredate di timestamp. FATTO

Consentire agli utenti di registrarsi, depositare e prelevare e vedere il proprio bilancio -> FATTO

Input e user authentication e validation. -> FATTO

Creare account editor per le modifiche la database. -> FATTO controllare db/fixed_setup.sql

Dare i privilegi strettamente necessari all'account di editor. -> FATTO controllare db/fixed_setup.sql

Includere timestamp formato yyyy-MM-dd HH:mm:ss nei log di php. -> FATTO

Sviluppare un logger che controlli che il database sia in uno stato consistente. -> FATTO

Ogni utente deve avere un ID univoco. -> FATTO, ogni utente è identificato dall'username, idem le transazioni sono identificate da un UUID

Hashamo le password. -> si pensa con SHA512 + un salt fisso. -> FATTO


## READ TEAM

Corrompere il database.

Corrompere le funzionalità del database.

Causare DoS al server tramite compromissione.
### apache2 -v

```
Server version: **Apache/2.4.29** (Ubuntu)
Server built:   2021-09-28T22:27:27
```
### mysql -V

```
mysql  Ver 14.14 Distrib **5.7.36**, for Linux (x86_64) using  EditLine wrapper
```
### php -v

```
PHP **7.2.24**-0ubuntu0.18.04.10 (cli) (built: Oct 25 2021 17:47:59) ( NTS )
Copyright (c) 1997-2018 The PHP Group
Zend Engine v3.2.0, Copyright (c) 1998-2018 Zend Technologies
    with Zend OPcache v7.2.24-0ubuntu0.18.04.10, Copyright (c) 1999-2018, by Zend Technologies
```
