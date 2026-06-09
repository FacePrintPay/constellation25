#!/data/data/com.termux/files/usr/bin/bash
# Track Agentik sale
echo "=== NEW SALE LOG ===" >> ~/revenue_log.txt
echo "Date: $(date)" >> ~/revenue_log.txt
echo "Payment: Cash App \$Kre8tiveKonceptz" >> ~/revenue_log.txt
read -p "Amount (\$49 or \$19): " AMOUNT
read -p "Product (Agentik/Premium/Stack): " PRODUCT
read -p "Customer note: " NOTE
echo "Amount: \$$AMOUNT" >> ~/revenue_log.txt
echo "Product: $PRODUCT" >> ~/revenue_log.txt
echo "Note: $NOTE" >> ~/revenue_log.txt
echo "Status: CONFIRMED" >> ~/revenue_log.txt
echo "---" >> ~/revenue_log.txt
TOTAL=$(grep -c 'CONFIRMED' ~/revenue_log.txt)
REVENUE=$(grep 'Amount:' ~/revenue_log.txt | awk -F'$' '{sum+=$2} END {print sum+0}')
echo ""
echo "✓ Sale logged!"
echo "Total licenses: $TOTAL"
echo "Total revenue: \$$REVENUE"
