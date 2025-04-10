### You are given an integer array prices where prices[i] is the price of a given stock on the ith day.

### On each day, you may decide to buy and/or sell the stock. You can only hold at most one share of the stock at any time. However, you can buy it then immediately sell it on the same day.

### Note the problem is confusing - given per day prices, you make no profit buying and selling on the same day! 

### Find and return the maximum profit you can achieve.

```python

fn total_profit(prices: List[UInt]) -> UInt:
    var total_profit: UInt = 0  # Stores the maximum profit found so far

    # Loop until sell day reaches the end of the price list
    for day in range(1, len(prices)):
        if prices[day - 1] < prices[day]:
            # If selling is profitable, sell it & add up profit
            total_profit += prices[day] - prices[day - 1]
    return total_profit  # Return the highest profit found


fn main():
    # First test: Best profit is buying at 1 and selling at 6 => profit = 5
    prices = List[UInt](7, 1, 5, 3, 6, 4)
    debug_assert(total_profit(prices) == 7, "Assertion failed")

    # Second test: No profitable day to sell => profit = 0
    prices = List[UInt](7, 6, 4, 3, 1)
    debug_assert(total_profit(prices) == 0, "Assertion failed")
    # 3rd test: Best profit is buying at every day and selling next day
    prices = List[UInt](1, 2, 3, 4, 5)
    debug_assert(total_profit(prices) == 4, "Assertion failed")

```

[Source](https://github.com/ratulb/mojo_programming/blob/main/codes/buy_and_sell_stock_2.mojo)
