# Gherkin Examples Tables — Best Practices

## When to Use Scenario Outline + Examples

```gherkin
# Good usage — same behaviour, different data
Scenario Outline: Refund rate calculation based on cancellation timing
  Given I cancel my booking of EUR <total_incl_tax> incl. tax with EUR <service_fees> in fees
  And departure is in <hours_remaining> hours
  When the refund calculation runs
  Then the refunded amount is EUR <refund_amount>

  Examples:
    | total_incl_tax | service_fees | hours_remaining | refund_amount |
    | 120            | 5            | 72              | 115           |
    | 120            | 5            | 36              | 57.50         |
    | 120            | 5            | 12              | 0             |
    | 200            | 5            | 72              | 195           |
    | 50             | 0            | 72              | 50            |

# Bad usage — different behaviours → use separate scenarios
Scenario Outline: Booking handling
  Given <situation>
  When <action>
  Then <result>

  Examples:
    | situation          | action  | result                 |
    | confirmed booking  | cancel  | refund issued          |
    | cancelled booking  | view    | show refund details    |
    | in-progress booking| cancel  | cancellation rejected  |
# → 3 different behaviours = 3 separate scenarios
```

## Column Structure

```gherkin
# Columns named in snake_case — readable, no spaces
Examples:
  | user_email       | password | expected_error_code |
  | invalid          | Pass1!   | INVALID_EMAIL       |
  | user@test.com    | abc      | WEAK_PASSWORD       |
  | taken@test.com   | Pass1!   | EMAIL_ALREADY_EXISTS|

# Multiple example groups with labels
Scenario Outline: Password validation
  Given I try to register with the password "<password>"
  Then I see the error "<error_message>"

  # Cases that are too short
  Examples: Insufficient length
    | password | error_message                       |
    | abc      | Minimum 8 characters required       |
    | 1234567  | Minimum 8 characters required       |

  # Cases missing required characters
  Examples: Insufficient complexity
    | password     | error_message                   |
    | alllowercase | An uppercase letter is required |
    | ALLUPPERCASE | A digit is required             |
    | NoSpecial1   | A special character is required |

  # Valid cases
  Examples: Accepted passwords
    | password    | error_message |
    | Pass1!xy    |               |
    | Str0ng#Pass |               |
```

## Complex Data — Doc String and DataTable

```gherkin
# DataTable for lists of multiple values
Scenario: Order with several items
  Given my cart contains the following items:
    | item            | unit_price | quantity |
    | Laptop          | 999.99     | 1        |
    | Wireless mouse  | 49.99      | 2        |
    | Mouse pad       | 19.99      | 1        |
  When I confirm my order
  Then the subtotal is EUR 1089.96
  And the total incl. tax is EUR 1307.95

# Doc String for long textual content
Scenario: Cancellation confirmation email
  Given I have cancelled my booking RES-2024-042
  When the confirmation email is sent
  Then the email contains the following text:
    """
    Your booking RES-2024-042 has been cancelled.
    Amount refunded: EUR 115.00
    Refund timeframe: 5 to 7 business days
    """
```

## Anti-Patterns with Tables

```gherkin
# Too many columns — scenario is unreadable
Examples:
  | id | email | pwd | role | country | verified | deleted | plan | trial |
  | 1  | a@b   | P1! | USER | FR      | true     | false   | FREE | false |

# Limit to 3-5 columns max — others are defaults

# Real production data in examples
Examples:
  | email               | card               |
  | john.doe@xxx.com    | 4111111111111111   |
  # → real data = risk, use clearly fictional test data

# Clearly fictional test data
Examples:
  | email                | test_card          |
  | testuser@example.com | 4242424242424242   |
  # 4242... = official Stripe test number
```
