SELECT card_id, card_type, sum(amount) as Total_spent
FROM transactions_data td 
INNER JOIN cards_data cd ON td.card_id = cd.id
GROUP BY 1
ORDER BY 3 DESC
LIMIT 100;

--Анализ риска по кредитному рейтингу клиентов:
SELECT 
	CASE WHEN credit_score > 800 THEN 'Отлично'
		 WHEN credit_score > 740 AND credit_score < 800 THEN 'Очень хорошо'
		 WHEN credit_score > 670 AND credit_score < 740 THEN 'Хорошо'
		 WHEN credit_score > 580 AND credit_score < 670 THEN 'Удовлетворительно'
		 WHEN credit_score > 300 AND credit_score < 580 THEN 'Плохо'
		 ELSE 'None'
	END AS credit_indicator,
	COUNT(ud.id) as clients_amount,
	ROUND(100.0 * COUNT(CASE WHEN fl.is_fraud = 1 THEN 1 END) / COUNT(*), 2) AS fraud_rate
	FROM users_data ud 
	RIGHT JOIN transaction_data td ON td.client_id = ud.id
	JOIN fraud_labels fl ON td.id = fl.fraud_index
	GROUP BY credit_indicator 
	Order by 2 DESC
	LIMIT 100;

--Выявление подозрительных транзакций
-- Необычно крупные суммы
  WITH client_stats AS (
    SELECT 
        t.client_id,
        AVG(t.amount) AS avg_amount,
        STDEV(t.amount) AS std_amount,
        u.yearly_income
    FROM transactions_data t
    JOIN users_data u ON t.client_id = u.id
    GROUP BY t.client_id, u.yearly_income
)
SELECT 
    t.id AS transaction_id,
    t.client_id,
    t.amount,
    t.tr_date,
    m.category AS merchant_category,
    cs.avg_amount AS client_avg_amount,
    cs.yearly_income,
    ROUND((t.amount/cs.yearly_income)*100, 2) AS percent_of_income,
    'Large amount' AS suspicion_reason
FROM transactions_data t
JOIN client_stats cs ON t.client_id = cs.client_id
LEFT JOIN mcc_codes m ON t.mcc = m.mcc_index
WHERE 
    (t.amount > cs.avg_amount + 3 * cs.std_amount
    OR t.amount > 0.5 * cs.yearly_income)
ORDER BY percent_of_income DESC;

--Топ-5 пользователей по количеству мошеннических транзакций
SELECT 
    u.id AS user_id,
    u.current_age,
    u.credit_score,
    COUNT(CASE WHEN f.is_fraud = 1 THEN 1 END) AS fraud_count
FROM 
    users_data u
JOIN 
    transactions_data t ON u.id = t.client_id
JOIN 
    fraud_labels f ON t.id = f.fraud_index 
GROUP BY 
    u.id, u.current_age, u.credit_score
ORDER BY 
    fraud_count DESC
LIMIT 5;

--Средний чек по категориям MCC с выделением мошеннических
SELECT 
    m.category,
    ROUND(AVG(t.amount), 2) AS avg_amount,
    COUNT(CASE WHEN f.is_fraud  = 1 THEN 1 END) AS fraud_count
FROM 
    transactions_data t
JOIN 
    mcc_codes m ON t.mcc = m.mcc_index
JOIN 
    fraud_labels f ON t.id = f.fraud_index
GROUP BY 
    m.category
ORDER BY 
    fraud_count DESC;

--Динамика мошенничества по месяцам
SELECT 
    date(t.tr_date, 'start of month') AS month,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN f.is_fraud = 1 THEN 1 ELSE 0 END) AS fraud_count,
    ROUND(100.0 * SUM(CASE WHEN f.is_fraud = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS fraud_percentage,
    SUM(SUM(CASE WHEN f.is_fraud = 1 THEN 1 ELSE 0 END)) OVER (ORDER BY date(t.tr_date, 'start of month')) AS cumulative_fraud
FROM 
    transactions_data t
JOIN 
    fraud_labels f ON t.id = f.fraud_index
GROUP BY 
    date(t.tr_date, 'start of month')
ORDER BY 
    month;