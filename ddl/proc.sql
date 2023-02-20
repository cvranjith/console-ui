create or replace PROCEDURE PR_VW_LOG
(
    p_id in varchar2  :=null,
    p_act in varchar2 :=null,
    p_fmt in varchar2 :=null,
    p_srch in varchar2 := null,
    p_del  in varchar2 := null,
    p_fetch_archived in varchar2 := 'N'
)
is
c constant varchar2(20):=chr(10);
l varchar2(32767);
--txt varchar2(32767);
c_parameters constant varchar2(200) := '#### Parameters';
fmt boolean := true;
last_time date := sysdate+9999;
srch varchar2(4000);
time_stamp varchar2(200);
dark_mode varchar2(2000) := '<a id="toggleDM" href="javascript:toggleDM();"> <span style="font-size:20px;">&#127767;</span></a>';
function cl(p_class in varchar2, p_txt in varchar2)
return varchar2
is
begin
    return case when not fmt then p_txt else '<span class="'|| p_class || '">' || p_txt || '</span>' end; 
end;
function sb(p_txt in varchar2)
return varchar2
is
begin
    return '[' || p_txt || ']'; 
end;
begin
    if p_fmt = 'none' then fmt := false; end if;
    if fmt
    then
        htp.print('<!DOCTYPE HTML> '||c||
'<html><head><title>'|| case when p_id is null then 'Logs' 
        else p_id || case when p_act is not null then '_' || p_act else null end end || '</title>' ||c||
'<style type="text/css"> '||c||
'.c1 { color:    #54b8dd    }'||c||
'.c2 { background:  #727678  ; color:  #d6eff9  }'||c||
'.c3 { color:   #61ad3c }'||c||
'.c4 { background:  #9b9da0  ; color: white }'||c||
'.c5 { background:  red  ; color: white }'||c||
'.c6 { background:  #587d37  ; color: white }'||c||
'.c7 { background:  #e3855f  ; color: white }'||c||
'a { color: #61ad3c; }</style>'||c||
'<style>'||c||
'body {'||c||
'  background-color: black;'||c||
'  color:  #d9dc9e ;'||c||
'}'||c||
'.dark-mode {'||c||
'  background-color: white;'||c||
'  color: black;'||c||
'}'||c||
'</style>'||c||
'<script>'||c||
'function toggleDM() {'||c||
'   var element = document.body;'||c||
'   element.classList.toggle("dark-mode");'||c||
'}'||c||
'</script>'||c||
'</head><body><pre lang="xml">');
    end if;
    if p_id is null
    or (p_id is not null and p_del = 'true')
    then
        if p_del = lower('TRUE')
        then
            update console.console_logs b
            set     archived = 'Y'
            where   exists (select 1 from VW_CONSOLE_LOGS a where a.id = p_id and a.rid = b.rowid); ---nvl (client_info, client_identifier|| '_' ||session_user)  = p_id;
        end if;
        if trim(p_srch) is not null
        then
            srch := '%'||upper(p_srch)|| '%';
        end if;
        htp.print(' <form action="logs" method="get">  '||dark_mode|| 
        '| <a href="arch_logs"> Old Logs </a>' ||
        ' <input type="text" id="srch" name="srch" placeholder="Grep..." value="' || p_srch || '"><input type="submit" value="&#128269;">
        <input type="checkbox" id="arch" name="arch" value="Y"'|| case when p_fetch_archived = 'Y' then ' checked' else null end || '>Incl. Arch.</input> </form> ');
        for i in (select * from vw_console_logs_summ2 a
        where ((nvl(p_fetch_archived,'N') = 'N' and archived = 'N') OR (nvl(p_fetch_archived,'N') = 'Y'))
        and (srch is null OR 
        (
            srch is not null and exists (
                select 1 from VW_CONSOLE_LOGS b
                where a.id = b.id
                and (
                       upper(b.id) like srch
                    or upper(b.act) like srch
                    or upper(b.message) like srch
                    or upper(b.call_stack) like srch
                )
            )
        ))
        order by log_time desc)
        loop
            l := null;
            for j in (select * from vw_console_logs_summ1 a where id = i.id 
            and (srch is null OR 
            (
            srch is not null and exists (
                select 1 from VW_CONSOLE_LOGS b
                where a.id = b.id
                and (
                       upper(b.id) like srch
                    or upper(b.act) like srch
                    or upper(b.message) like srch
                    or upper(b.call_stack) like srch
                )
            )
            ))
            order by log_time desc)
            loop
                l := l|| '| <a href=logs?id=' || i.id || chr(38)|| 'act=' || j.act || '>' ||j.act|| '</a> ';
            end loop;
            htp.print( '<a href=logs?id=' || i.id || chr(38)|| 'del=true> '|| chr(38) || '#128465;</a> <a href=logs?id=' || i.id || '>' ||rpad(i.id,35,' ')|| '</a> |'||i.log_time|| l);
        end loop;
    else
        if fmt
        then
            htp.print(dark_mode|| ' | <a href="logs">&#x1F3E0; Logs</a> | <a href="logs?id=' || p_id || chr(38)|| 'act'|| '=' || p_act|| 
             chr(38)|| 'fmt=none" download="' || p_id || case when p_act is not null then '_'||p_act else null end 
             || '.txt">&#x1F4BE; Download</a> <br>');
        end if;
        for i in (select * from VW_CONSOLE_LOGS where id = p_id and nvl(act,'*') = nvl(p_act,nvl(act,'*')) order by log_time)
        loop 
            if trunc(last_time) = trunc(i.log_time)
            then
                time_stamp := to_char(i.log_time,'HH24:MI:SS.FF3');
            else
                time_stamp := to_char(i.log_time,'DD-MON-YY HH24:MI:SS.FF3');
            end if;
            last_time := i.log_time;
            if nvl(instr(i.message,c_parameters),0) > 0 then
            --if i.message like '%#### Parameters%' then
                i.message := replace(i.message,c_parameters, rpad(' ',85,' ')|| c_parameters); 
                i.message := replace(i.message,chr(10)|| '|', chr(10) || rpad(' ',85,' ') || '|' );
            end if;
            htp.print( sb(cl('c1', time_stamp))
                    || sb(cl('c2', replace(i.scope,', line ',':')))
                    || sb(cl( case when nvl(instr(lower(i.level_name), 'err'),0) > 0 then 'c5' else 'c6' end , i.level_name))
                    || sb(cl('c3',i.act))
                    || ' ' || rtrim( 
                        (
                            case when fmt then
                            replace(replace(i.message,'<', chr(38) || 'lt;'),'>', chr(38) || 'gt;')
                            else i.message
                            end
                        ),
                        chr(10))
                    );
            if i.call_stack is not null
            then
                htp.print(cl('c7',replace(i.call_stack,chr(10)||chr(10),chr(10))));
            end if;
        end loop;
    end if;
    if fmt
    then
        htp.print('</pre></body></html>');
    end if;
end;
