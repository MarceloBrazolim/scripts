import datetime

# Get the initial card fund from the user
funds = float(input("Enter the initial card fund: "))

# Get the card type from the user (VE or VC)
card_type = input("Enter the card type (VE or VC): ").upper()

# Get the amount of rides the user takes per day
rideAmounts = int(input("Enter the total amount of trips you take per day (back and forth): "))

# Initialize the date, expenditure and fare variables
current_date = datetime.date.today()
expenditure = 0
fareVE, fareVC = 2.2, 4.4

# Define a function to calculate the expenditure based on card type
def calculate_expenditure(card_type, current_date):
    if card_type == "VE":
        if current_date.weekday() not in [1, 5, 6]:  # Not Tuesday or weekend (0=Monday, 1=Tuesday, ..., 6=Sunday)
            return (rideAmounts * fareVE)
        else:
            return 0  # No expenditure on Tuesdays or weekends
    elif card_type == "VC":
        if current_date.weekday() not in [1, 5, 6]:  # Not Tuesday or weekend
            return (rideAmounts * fareVC)
        else:
            return 0  # No expenditure on Tuesdays or weekends
    else:
        return 0  # Invalid card type

# Calculate and print the predicted date when the card will be out of funds
expenditure = calculate_expenditure(card_type, current_date)
if expenditure > 0:
    funds -= expenditure
threshold = (rideAmounts * fareVE) if card_type == "VE" else ((rideAmounts * fareVC) if card_type == "VC" else 0)
while funds >= threshold:
    current_date += datetime.timedelta(days=1)
    expenditure = calculate_expenditure(card_type, current_date)
    if expenditure > 0:
        funds = round(funds - expenditure, 2)

print(f"The card can only be used until: {current_date}")
print(f"The remaining funds on the card is: {funds}")
