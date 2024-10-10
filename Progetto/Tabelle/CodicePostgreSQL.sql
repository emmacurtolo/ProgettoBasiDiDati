
create domain dom_email as varchar check(value ~'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$');
create domain dom_tel as varchar check(value ~ '[0-9]{10}');
create domain dom_id_ordine as varchar check(value ~ '[A-Z]{2}[0-9]{4}');
create domain dom_matricola as varchar check(value ~ '[0-9]{4}');




CREATE TABLE DIPENDENTE (
	matricola dom_matricola PRIMARY KEY,
	nome varchar(30) NOT NULL,
	cognome varchar(30) NOT NULL,
	data_di_nascita date NOT NULL,
	coniuge int default NULL,
	data_matrimonio date default NULL,
	qualifica varchar(30) NOT NULL,
	data_assunzione date NOT NULL,
	laurea varchar(50) default NULL,
	data_laurea date default NULL,
	dottorato varchar(50) default NULL,
	data_dottorato date default NULL,
	dipartimento varchar(50) NOT NULL
);

CREATE TABLE COMPETENZA(
	tipo varchar(50) PRIMARY KEY
);

CREATE TABLE FORNITORE (
	nome_fornitore varchar(50),
	indirizzo varchar(100),
	PRIMARY KEY (nome_fornitore, indirizzo)
);

CREATE TABLE DIPARTIMENTO(
	nome varchar(50) PRIMARY KEY,
	telefono dom_tel NOT NULL UNIQUE,
	email dom_email NOT NULL UNIQUE,
	data_ultimo_acquisto date NOT NULL,
	nome_ultimo_fornitore varchar(50) NOT NULL,
	indirizzo_ultimo_fornitore varchar(100) NOT NULL,
	FOREIGN KEY (nome_ultimo_fornitore, indirizzo_ultimo_fornitore) REFERENCES FORNITORE(nome_fornitore, indirizzo)
	ON UPDATE CASCADE ON DELETE CASCADE
);

ALTER TABLE DIPENDENTE
add constraint dipartimento
FOREIGN KEY(dipartimento) REFERENCES DIPARTIMENTO(nome);


CREATE TABLE PROGETTO (
	codice_progetto_aziendale int PRIMARY KEY,
	budget int NOT NULL,
	durata int NOT NULL constraint durata_valida check (durata > 0)
);

ALTER TABLE PROGETTO
add constraint budget_limiti 
check (budget between 1000 and 200000);


CREATE TABLE HA_COMPETENZE(
	tipo_competenza varchar(50) NOT NULL,
	dipendente dom_matricola NOT NULL,
	PRIMARY KEY (tipo_competenza, dipendente),
	FOREIGN KEY (tipo_competenza) REFERENCES COMPETENZA(tipo) ON UPDATE CASCADE ON DELETE CASCADE,  
	FOREIGN KEY (dipendente) REFERENCES DIPENDENTE(matricola) ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE APPROVVIGIONA(
	id_ordine dom_id_ordine PRIMARY KEY,
	nome_fornitore varchar(50) NOT NULL,
	indirizzo_fornitore varchar(100) NOT NULL,
	nome_dipartimento varchar(50) NOT NULL,
	data date NOT NULL, 
	FOREIGN KEY (nome_fornitore, indirizzo_fornitore) REFERENCES FORNITORE(nome_fornitore, indirizzo)
	ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (nome_dipartimento) REFERENCES DIPARTIMENTO(nome)
	ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE LAVORA_A(
	matricola_dipendente dom_matricola NOT NULL,
	codice_progetto int NOT NULL,
	competenza varchar(50) NOT NULL,
	PRIMARY KEY (matricola_dipendente, codice_progetto, competenza),
	FOREIGN KEY (competenza, matricola_dipendente) REFERENCES HA_COMPETENZE(tipo_competenza, dipendente) ON UPDATE CASCADE ON DELETE CASCADE, 
	FOREIGN KEY (codice_progetto) REFERENCES PROGETTO(codice_progetto_aziendale) ON UPDATE CASCADE ON DELETE CASCADE
);











