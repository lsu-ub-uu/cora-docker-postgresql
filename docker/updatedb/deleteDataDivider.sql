delete from link
where (fromtype,fromid,totype,toid) in (
  select l.* from link l
  join record r on l.fromtype = r."type" and l.fromid = r.id
  where r.datadivider = :'dataDivider'
  order by fromtype, fromid, totype, toid
);

delete from storageterm
where id in (
  select s.id
  from storageterm s
  join record r on s.recordtype = r."type" and s.recordid = r.id
  where r.datadivider = :'dataDivider'
  order by recordtype, recordid
);

delete from record where datadivider = :'dataDivider';