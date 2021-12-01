# AuctionContract
Functionality for all kinds of auctions, where people compete to acquire various assets

## Overview
Each AuctionContract instance is produced by calling `AuctionFactory.produce(AuctionParams params)`, setting default parameters which include:

### AuctionParams
* `uint32 duration` in seconds, 0 means no auction end time, so it must be finished or canceled by owner
* `address currency` (ERC20 contract, or `0x0` means native coin)
* `uint256 startingBid` the first bid that starts the auction
* `uint256 minimumIncrease` the minimum difference between bids
* `uint256 retainFraction` the amount to refund when outbid, ranging between 0 and `FRACTION=100000` (default is 0)

<table>
<thead>
	<tr>
		<th>method name</th>
		<th>called by</th>
		<th>description</th>
	</tr>
</thead>
<tbody>
	<tr>
		<td><a href="#create">create</a></td>
		<td>anyone</td>
		<td>creates a new auction with default parameters, return auction `id`</td>
	</tr>
	<tr>
		<td><a href="#bid">bid</a></td>
		<td>anyone</td>
		<td>bid in an existing auction, at least `minimumBid` more than last bid. If successful, the previous bidder has tokens returned in the amount of `bidAmount.mul(FRACTION-retainFraction).div(FRACTION)`</td>
	</tr>
	<tr>
		<td><a href="#cancel">cancel</a></td>
		<td>owner</td>
		<td>can be called by the owner to cancel the auction, at any time</td>
	</tr>
	<tr>
		<td><a href="#complete">complete</a></td>
		<td>owner</td>
		<td>can be called by the owner to complete an auction</td>
	</tr>
	<tr>
		<td><a href="#withdraw">withdraw</a></td>
		<td>owner</td>
		<td>called by owner to withdraw the funds from the auction and send them to an address</td>
	</tr>
	<tr>
		<td><a href="#transferownership">transferOwnership</a></td>
		<td>owner</td>
		<td>transferOwnership</td>
	</tr>
    <tr>
		<td><a href="#setparameters">setParameters</a></td>
		<td>owner</td>
		<td>update default settings</td>
	</tr>
    <tr>
		<td><a href="#prolong">prolong</a></td>
		<td>owner</td>
		<td>prolonging expired auction</td>
	</tr>
	<tr>
		<td><a href="#getwinner">getWinner</a></td>
		<td>anyone</td>
		<td>view auction's winner</td>
	</tr>
	<tr>
		<td><a href="#gethistory">getHistory</a></td>
		<td>anyone</td>
		<td>view history of bids</td>
	</tr>
</tbody>	
</table>

## Methods

#### create
creating auction and make first bid
Params:    
name  | type | description
--|--|--
id|uint256|auction id

#### bid
making bid for auction with `id`
Params:    
name  | type | description
--|--|--
id|uint256|auction id

#### cancel
canceling auction with `id`
Params:    
name  | type | description
--|--|--
id|uint256|auction id

#### complete
completing auction with `id`
Params:    
name  | type | description
--|--|--
id|uint256|auction id

#### withdraw
transfer funds from last bid auction `id` to address `to`
Params:    
name  | type | description
--|--|--
id|uint256|auction id
to|address|address 

#### transferOwnership
transferOwnership to address `to`
Params:    
name  | type | description
--|--|--
to|address|address 

#### setParameters
method will set default settings
Params:    
name  | type | description
--|--|--
duration|uint256|duration
minimumBid|uint256|minimumBid
minimumIncrease|uint256|minimumIncrease

#### prolong
prolonging еxpired auction `id` for `duration` from the timestamp of transaction
Params:    
name  | type | description
--|--|--
id|uint256|auction id

#### getWinner
view address of the winner of auction `id`
Params:    
name  | type | description
--|--|--
id|uint256|auction id

#### getHistory
view history of bids by auction `id` (consider pushing AuctionBid structs onto an array, and using [this pagination pattern](https://ethereum.stackexchange.com/a/70558/19734) to traverse it backwards)
Params:    
name  | type | description
--|--|--
id|uint256|auction id
from|uint256|0 is most recent
limit|uint256|number of entries going chronologically

#### AuctionBid
auctionId, bidder, currency, amount, timestamp
