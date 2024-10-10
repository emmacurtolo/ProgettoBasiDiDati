/* Calcolo data maggiore per l'ultimo acquisto 
SELECT data_ultimo_acquisto(Sales) FROM approvvigiona;	
*/
CREATE OR REPLACE FUNCTION 
data_ultimo_acquisto(dip varchar)
RETURNS date
LANGUAGE plpgsql AS $$
	DECLARE
		data_max date;
	BEGIN
		select max(data) INTO data_max
		from approvvigiona
		where nome_dipartimento = dip;

		RETURN data_max;
	END
$$;
/* Calcolo nome ultimo fornitore 
SELECT nome_fornitore_ultimo_acquisto(data_ultimo_acquisto(Sales), Sales) from approvvigiona; 	
*/
CREATE OR REPLACE FUNCTION 
nome_fornitore_ultimo_acquisto(data_max date, dip varchar)
RETURNS varchar
LANGUAGE plpgsql AS $$
  DECLARE
    nome_ultimo_fornitore varchar;
  BEGIN
    select nome_fornitore INTO nome_ultimo_fornitore
    from approvvigiona
    where data = data_max and nome_dipartimento = dip;

    RETURN nome_ultimo_fornitore;
  END
$$;

/* Calcolo indirizzo ultimo fornitore 
SELECT indirizzo_fornitore_ultimo_acquisto(data_ultimo_acquisto(Sales), Sales) from approvvigiona;
*/
CREATE OR REPLACE FUNCTION 
indirizzo_fornitore_ultimo_acquisto(data_max date, dip varchar)
RETURNS varchar
LANGUAGE plpgsql AS $$
  DECLARE
    indirizzo_ultimo_fornitore varchar;
  BEGIN
    select indirizzo_fornitore INTO indirizzo_ultimo_fornitore
    from approvvigiona
    where data = data_max and nome_dipartimento = dip;

    RETURN indirizzo_ultimo_fornitore;
  END
$$;

/* 
	Trigger 1: Non puoi sposarti con te stesso
*/
create or replace function valida_matrimonio()
returns trigger as
$$
  	begin
   		perform * 
   		from dipendente 
   		where CAST(new.matricola as int) = new.coniuge;

    	if found
    	then
    		raise exception 'Matrimonio non consentito';
      		return null;
    	else
      		return new;
    	end if;
  	end;
$$ language plpgsql;

create trigger matrimonio before 
insert or update 
on dipendente 
for each row 
execute procedure valida_matrimonio();

/* 
  Trigger 2: La data della laurea deve essere antecedente a quella del dottorato
*/
create or replace function valida_date_studi()
returns trigger as
$$
    begin
      perform * 
      from dipendente 
      where data_laurea < new.data_dottorato;

      if found
      then
        raise exception 'Data non conforme';
          return null;
      else
          return new;
      end if;
    end;
$$ language plpgsql;

create trigger date_studi before 
insert or update 
on dipendente 
for each row 
execute procedure valida_date_studi();

/* 
  Trigger 3: assunzione di sole persone maggiorenni (18 anni = 6570 giorni)
*/
create or replace function valida_maggiorenni()
returns trigger as
$$
    begin
      perform * 
      from dipendente 
      where DATE_PART('year', new.data_assunzione::date) - DATE_PART('year', new.data_di_nascita::date) < 18;

      if found
      then
        raise exception 'Data assunzione non conforme';
          return null;
      else
          return new;
      end if;
    end;
$$ language plpgsql;

create trigger assunto_maggiorenne before 
insert or update 
on dipendente 
for each row 
execute procedure valida_maggiorenni();

/* 
  Trigger 4: deve esserci la data del matrimonio
*/
create or replace function valida_data_matrimonio_coniuge()
returns trigger as
$$
    begin
      perform * 
      from dipendente 
      where (new.coniuge is not null and new.data_matrimonio is null)
      		or (new.coniuge is null and new.data_matrimonio is not null);

      if found
      then
        raise exception 'Attributo (coniuge o data) mancante nella relazione di matrimonio';
          return null;
      else
          return new;
      end if;
    end;
$$ language plpgsql;

create trigger data_matrimonio_coniuge before 
insert or update 
on dipendente 
for each row 
execute procedure valida_data_matrimonio_coniuge();

/* Inserimenti per controllare il corretto funzionamento dei trigger */
insert into dipendente(matricola, nome, cognome, data_di_nascita, coniuge, data_matrimonio, qualifica, data_assunzione, laurea, data_laurea, dottorato, data_dottorato, dipartimento)
values (3782, 'Anna', 'Red', '2006/07/12', null, null, 'Operaio', '2020/01/01', null, null, null, null, 'Sales'); /* data assunzione non conforme */
 
insert into dipendente(matricola, nome, cognome, data_di_nascita, coniuge, data_matrimonio, qualifica, data_assunzione, laurea, data_laurea, dottorato, data_dottorato, dipartimento)
values (2098, 'Mara', 'Yellow', '1995/08/23', '2098', '2018/06/06', 'Analista', '2019/04/25', 'Matematica', '2017/10/16', null, null, 'Sales'); /* matrimonio non consentito */
 
insert into dipendente(matricola, nome, cognome, data_di_nascita, coniuge, data_matrimonio, qualifica, data_assunzione, laurea, data_laurea, dottorato, data_dottorato, dipartimento)
values (2212, 'Cara', 'Green', '1990/11/02', null, null, 'Commerciale', '2020/03/15', 'Banca e finanza', '2020/03/03', 'Economia', '2019/07/07', 'Sales'); /* Errore date laurea e dottorato */
 
insert into dipendente(matricola, nome, cognome, data_di_nascita, coniuge, data_matrimonio, qualifica, data_assunzione, laurea, data_laurea, dottorato, data_dottorato, dipartimento)
values (5957, 'John', 'White', '1987/07/12', null, null, 'Amministrativo', '2020/02/02', 'Architettura', '2019/07/07', null, null, 'Administration'); /* OK */

insert into dipendente(matricola, nome, cognome, data_di_nascita, coniuge, data_matrimonio, qualifica, data_assunzione, laurea, data_laurea, dottorato, data_dottorato, dipartimento)
values (5957, 'Ralph', 'Pink', '1977/07/12', null, '2021/02/10', 'Progettista', '2017/02/02', 'Informatica', '2015/05/10', null, null,  'IT'); /* Errore mancanza laurea */
