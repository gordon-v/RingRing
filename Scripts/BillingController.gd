extends Control
class_name BillingController

var payment
var purchasedItem = null

var player_stats: PlayerStats
enum ItemPurchased {
	Stars100,
	Stars500,
	Stars1500,
	Stars5000,
	NoAds
}
# Matches BillingClient.ConnectionState in the Play Billing Library
enum ConnectionState {
	DISCONNECTED, # not yet connected to billing service or was already closed
	CONNECTING, # currently in process of connecting to billing service
	CONNECTED, # currently connected to billing service
	CLOSED, # already closed and shouldn't be used again
}

# Matches Purchase.PurchaseState in the Play Billing Library
enum PurchaseState {
	UNSPECIFIED,
	PURCHASED,
	PENDING,
}

func _ready():
	player_stats = get_tree().get_first_node_in_group("PlayerStats")

	if Engine.has_singleton("GodotGooglePlayBilling"):
		payment = Engine.get_singleton("GodotGooglePlayBilling")

		# These are all signals supported by the API
		# You can drop some of these based on your needs
		payment.billing_resume.connect(_on_billing_resume) # No params
		payment.connected.connect(_on_connected) # No params
		#payment.disconnected.connect(_on_disconnected) # No params
		#payment.connect_error.connect(_on_connect_error) # Response ID (int), Debug message (string)
		#payment.price_change_acknowledged.connect(_on_price_acknowledged) # Response ID (int)
		payment.purchases_updated.connect(_on_purchases_updated) # Purchases (Dictionary[])
		payment.purchase_error.connect(_on_purchase_error) # Response ID (int), Debug message (string)
		payment.sku_details_query_completed.connect(_on_product_details_query_completed) # Products (Dictionary[])
		payment.sku_details_query_error.connect(_on_product_details_query_error) # Response ID (int), Debug message (string), Queried SKUs (string[])
		payment.purchase_acknowledged.connect(_on_purchase_acknowledged) # Purchase token (string)
		payment.purchase_acknowledgement_error.connect(_on_purchase_acknowledgement_error) # Response ID (int), Debug message (string), Purchase token (string)
		payment.purchase_consumed.connect(_on_purchase_consumed) # Purchase token (string)
		payment.purchase_consumption_error.connect(_on_purchase_consumption_error) # Response ID (int), Debug message (string), Purchase token (string)
		payment.query_purchases_response.connect(_on_query_purchases_response) # Purchases (Dictionary[])
		payment.startConnection()
	else:
		print("Android IAP support is not enabled. Make sure you have enabled 'Gradle Build' and the GodotGooglePlayBilling plugin in your Android export settings! IAP will not work.")

func purchase100() -> void:
	if payment:
		payment.purchase("star100sku")

func purchase500() -> void:
	if payment:
		payment.purchase("star500sku")
	
func purchase1500() -> void:
	if payment:
		payment.purchase("star1500sku")
	
func purchase5000() -> void:
	if payment:
		payment.purchase("star5000sku")

func purchaseNoAds() ->void:
	if payment:
		payment.purchase("noads")


func _on_connected():
	payment.querySkuDetails(["star100sku", "star500sku", "star1500sku", "star5000sku", "noads"], "inapp") # "subs" for subscriptions
	#_on_billing_resume()

func _on_product_details_query_completed(product_details):
	for available_product in product_details:
		#print(available_product)
		pass

func _on_product_details_query_error(response_id, error_message, products_queried):
	print("on_product_details_query_error id:", response_id, " message: ",
			error_message, " products: ", products_queried)

func _query_purchases():
	payment.queryPurchases("inapp") # Or "subs" for subscriptions

func _on_query_purchases_response(query_result):
	if query_result.status == OK:
		for purchase in query_result.purchases:
			_process_purchase(purchase)
			pass
	else:
		print("queryPurchases failed, response code: ",
				query_result.response_code,
				" debug message: ", query_result.debug_message)
func _on_billing_resume():
	if payment.getConnectionState() == ConnectionState.CONNECTED:
		_query_purchases()
		
func _on_purchases_updated(purchases):
	for purchase in purchases:
		_process_purchase(purchase)

func _on_purchase_error(response_id, error_message):
	print("purchase_error id:", response_id, " message: ", error_message)
	
func _process_purchase(purchase):
	#print(str(purchase))
	print("Processing purchase:"+ str(purchase.order_id))
	if "star100sku" in purchase.sku and purchase.purchase_state == PurchaseState.PURCHASED:
		# Add code to store payment so we can reconcile the purchase token
		# in the completion callback against the original purchase
		purchasedItem = ItemPurchased.Stars100
		payment.consumePurchase(purchase.purchase_token)
	elif "star500sku" in purchase.sku and purchase.purchase_state == PurchaseState.PURCHASED:
		# Add code to store payment so we can reconcile the purchase token
		# in the completion callback against the original purchase
		purchasedItem = ItemPurchased.Stars500
		payment.consumePurchase(purchase.purchase_token)
		
	if "star1500sku" in purchase.sku and purchase.purchase_state == PurchaseState.PURCHASED:
		# Add code to store payment so we can reconcile the purchase token
		# in the completion callback against the original purchase
		purchasedItem = ItemPurchased.Stars1500
		payment.consumePurchase(purchase.purchase_token)
	if "star5000sku" in purchase.sku and purchase.purchase_state == PurchaseState.PURCHASED:
		# Add code to store payment so we can reconcile the purchase token
		# in the completion callback against the original purchase
		purchasedItem = ItemPurchased.Stars5000
		payment.consumePurchase(purchase.purchase_token)
	if "noads" in purchase.sku and purchase.purchase_state == PurchaseState.PURCHASED:
		purchasedItem = ItemPurchased.NoAds
		payment.acknowledgePurchase(purchase.purchase_token)
		
func _on_purchase_consumed(purchase_token):
	_handle_purchase_token(purchase_token, true)

func _on_purchase_consumption_error(response_id, error_message, purchase_token):
	print("_on_purchase_consumption_error id:", response_id,
			" message: ", error_message)
	_handle_purchase_token(purchase_token, false)

# Find the sku associated with the purchase token and award the
# product if successful
func _handle_purchase_token(_purchase_token, purchase_successful):
	print("handling purchase token"+"purchase success="+str(purchase_successful))
	# check/award logic, remove purchase from tracking list
	if purchase_successful:
		print("purchase successfull, awarding stars")
		if purchasedItem == ItemPurchased.Stars100:
			player_stats.add_stars(100)
			(get_tree().get_first_node_in_group("MessageManager") as MessageManager).push_message(1,"Purchase Successful","100 Stars added to your account!")
		elif purchasedItem == ItemPurchased.Stars500:
			player_stats.add_stars(500)
			(get_tree().get_first_node_in_group("MessageManager") as MessageManager).push_message(2,"Purchase Successful","500 Stars added to your account!")
		elif purchasedItem == ItemPurchased.Stars1500:
			player_stats.add_stars(1500)
			(get_tree().get_first_node_in_group("MessageManager") as MessageManager).push_message(3,"Purchase Successful","1500 Stars added to your account!")
		elif purchasedItem == ItemPurchased.Stars5000:
			player_stats.add_stars(5000)
			(get_tree().get_first_node_in_group("MessageManager") as MessageManager).push_message(4,"Purchase Successful","5000 Stars added to your account!")
		purchasedItem == null
	else:
		(get_tree().get_first_node_in_group("MessageManager") as MessageManager).push_message(1,"Purchase Unsuccessful","Check your funds or try again later")
		
	
func _on_purchase_acknowledged(_token: String) -> void:
	if purchasedItem == ItemPurchased.NoAds and player_stats.noads_token != _token:
		print("purchase acknowledged succesfully")
		(get_tree().get_first_node_in_group("MessageManager") as MessageManager).push_message(1,"Account Upgraded","You have bought a permanent ad free experience!")
		player_stats.removeAds()		
		purchasedItem == null
		player_stats.noads_token = _token
	
	
func _on_purchase_acknowledgement_error(response_id, error_message, _purchase_token) ->void:
	print_debug("Error acknowledging purchase, response_id: "+str(response_id)+" Message: "+str(error_message))


func _on_player_stats_updated_rings() -> void:
	_query_purchases()
