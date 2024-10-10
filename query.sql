1. I dipendenti assunti negli ultimi 12 mesi
select nome, cognome, data_assunzione from dipendente
where data_assunzione between '2020-03-01' and '2021-03-01';

2. I dipendenti che lavorano allo stesso progetto insieme al coniuge
-- Non funziona, da cambiare
select d.matricola, d.coniuge 
from dipendente as d
where not exists (select *
					from lavora_a as la
					where la.matricola_dipendente <> d.matricola
						and not exists (select * from lavora_a as la1 
						where la1.matricola_dipendente <> d.coniuge 
						and la.codice_progetto = la1.codice_progetto));

3. I/il dipartimenti/o che hanno/ha fatto più ordini negli ultimi 12 mesi
create view max_a as 
select count(id_ordine) as nordine
from approvvigiona 
group by nome_dipartimento;

select a.nome_dipartimento, count(a.id_ordine) as nordine
from approvvigiona as a
group by a.nome_dipartimento
having count(a.id_ordine) = (select max(ma.nordine) from max_a as ma);

4. Le competenze che vengono usate più di 5 volte nei progetti
select la.competenza, count(la.competenza) as ncomp 
from lavora_a as la
group by la.competenza
having count(la.competenza) > 5
order by count(la.competenza) desc;
								
5. I dipendenti che hanno lavorato ad almeno tre progetti. 
SELECT distinct LA1.matricola_dipendente
FROM LAVORA_A AS LA1, LAVORA_A AS LA2, LAVORA_A AS LA3
WHERE LA1.matricola_dipendente=LA2.matricola_dipendente AND
      LA2.matricola_dipendente=LA3.matricola_dipendente AND							
      LA1.codice_progetto<>LA2.codice_progetto AND
      LA1.codice_progetto<>LA3.codice_progetto AND
      LA3.codice_progetto<>LA2.codice_progetto;
								
6. I dipendenti che hanno lavorato ad almeno due progetti.
SELECT distinct LA1.matricola_dipendente
FROM LAVORA_A AS LA1, LAVORA_A AS LA2
WHERE LA1.matricola_dipendente=LA2.matricola_dipendente AND							
      LA1.codice_progetto<>LA2.codice_progetto;
								
      
