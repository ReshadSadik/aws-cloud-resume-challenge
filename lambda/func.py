import boto3
def lambda_handler(event, context):
    try:
        # Initialize a session using Amazon DynamoDB
        dynamodb = boto3.resource('dynamodb')
        # Select your DynamoDB table
        table = dynamodb.Table('cloudresumecounter')
        # Retrieve the current item with primary key 'id'
        response = table.get_item(Key={'id': '1'})
        # Extract the current views count, defaulting to 0 if not found
        current_views = response.get('Item', {}).get('viewCount', 0)
        # Increment the views count by 1
        new_views = current_views + 1
        # Update the item in DynamoDB with the new views count
        table.update_item(
            Key={'id': '1'},  # Primary key
            UpdateExpression="SET viewCount = :new_views",  # Update the views field
            ExpressionAttributeValues={
                ':new_views': new_views  # The new incremented views count
            }
        )
        # Return the updated views count
        return {"number": new_views}
    except Exception as e:
        # Handle any errors that occur during the process
        return {"error": str(e)}