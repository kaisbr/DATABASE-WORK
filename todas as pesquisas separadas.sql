-- select do modelo star
SELECT 
    v.id,
    v.quantidade,
    t.ano,
    p.nome_produto,
    c.nome_cliente,
    f.nome_funcionario,
    l.cidade,
    SUM(v.valor) AS total_vendas
FROM
    vendas_fato v
        JOIN
    dim_tempo t ON tempo_id = t.id
        JOIN
    dim_produto p ON produto_id = p.id
        JOIN
    dim_cliente c ON cliente_id = c.id
        JOIN
    dim_funcionario f ON funcionario_id = f.id
        JOIN
    dim_local l ON local_id = l.id
GROUP BY v.id , t.ano , c.nome_cliente , f.nome_funcionario , l.cidade , p.nome_produto , v.quantidade;

-- perguntas do database restaurante

