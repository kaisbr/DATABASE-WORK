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


-- cliente que mais pede em cada ano

SELECT ano, c.nome_cliente, ranked.id_cliente, total_pedidos
FROM (
    SELECT
        YEAR(m.data_hora_entrada) AS ano,
        m.id_cliente,
        COUNT(*) AS total_pedidos,
        ROW_NUMBER() OVER (PARTITION BY YEAR(m.data_hora_entrada) ORDER BY COUNT(*) DESC) AS ranking
    FROM
        tb_mesa m
    GROUP BY
        YEAR(m.data_hora_entrada), m.id_cliente
) AS ranked
JOIN tb_cliente c ON c.id_cliente = ranked.id_cliente
WHERE ranking = 1;

-- cliente que mais gastou em todos os anos

SELECT 
    c.id_cliente,
    c.nome_cliente,
    SUM(pr.preco_unitario_prato * p.quantidade_pedido) AS total_gasto
FROM 
    tb_pedido p
JOIN 
    tb_prato pr ON p.codigo_prato = pr.codigo_prato
JOIN 
    tb_mesa m ON p.codigo_mesa = m.codigo_mesa
JOIN 
    tb_cliente c ON m.id_cliente = c.id_cliente
GROUP BY 
    c.id_cliente, c.nome_cliente
ORDER BY 
    total_gasto DESC
LIMIT 1;

-- cliente que trouxe mais pessoas

SELECT 
    YEAR(m.data_hora_entrada) AS ano,
    c.nome_cliente,
    m.id_cliente,
    SUM(m.num_pessoa_mesa) AS total_pessoas
FROM 
    tb_mesa m
JOIN 
    tb_cliente c ON m.id_cliente = c.id_cliente
GROUP BY 
    YEAR(m.data_hora_entrada),
    m.id_cliente,
    c.nome_cliente
ORDER BY 
    YEAR(m.data_hora_entrada) DESC,
    total_pessoas DESC
LIMIT 1;

-- empresa que tem mais funcionarios clientes

SELECT
    e.nome_empresa,
    COUNT(c.email_cliente) AS total_funcionarios
FROM
    tb_cliente c
JOIN
    tb_beneficio b ON c.email_cliente = b.email_funcionario
JOIN
    tb_empresa e ON b.codigo_empresa = e.codigo_empresa
GROUP BY
    e.nome_empresa
ORDER BY
    total_funcionarios DESC
LIMIT 1;

-- empresas que mais funcionarios pedem sobremesa em cada ano

SELECT
    ano,
    nome_empresa,
    total_funcionarios_sobremesa
FROM
    (
        SELECT
            YEAR(m.data_hora_entrada) AS ano,
            e.nome_empresa,
            COUNT(DISTINCT c.email_cliente) AS total_funcionarios_sobremesa,
            ROW_NUMBER() OVER (PARTITION BY YEAR(m.data_hora_entrada) ORDER BY COUNT(DISTINCT c.email_cliente) DESC) AS ranking
        FROM
            tb_mesa m
        JOIN
            tb_cliente c ON m.id_cliente = c.id_cliente
        JOIN
            tb_pedido p ON m.codigo_mesa = p.codigo_mesa
        JOIN
            tb_prato pr ON p.codigo_prato = pr.codigo_prato
        JOIN
            tb_tipo_prato tp ON pr.codigo_tipo_prato = tp.codigo_tipo_prato
        JOIN
            tb_beneficio b ON c.email_cliente = b.email_funcionario
        JOIN
            tb_empresa e ON b.codigo_empresa = e.codigo_empresa
        WHERE
            tp.nome_tipo_prato = 'Sobremesa'
        GROUP BY
            YEAR(m.data_hora_entrada), e.nome_empresa
    ) AS ranking
WHERE
    ranking = 1;


