import asyncio
import websockets
import pyautogui
import json
import time
from collections import deque

# Configuration
SMOOTHING_WINDOW_SIZE = 6  # Number of samples to average (adjust as needed)
UPDATE_RATE = 0.0016  # How frequently to update the cursor position (in seconds)
ACCELERATION_FACTOR = 1.2  # Increase this for faster movement on larger deltas
MIN_MOVEMENT_THRESHOLD = 0.5  # Ignore very tiny movements to reduce jitter

# Movement data storage
movement_buffer = deque(maxlen=SMOOTHING_WINDOW_SIZE)
last_update_time = 0

async def movement_processor():
    """Process accumulated movements at a consistent frame rate"""
    while True:
        current_time = time.time()
        
        if movement_buffer:
            # Calculate the average movement from the buffer
            total_dx, total_dy = 0, 0
            samples = len(movement_buffer)
            
            if samples > 0:
                for dx, dy in movement_buffer:
                    total_dx += dx
                    total_dy += dy
                
                avg_dx = total_dx / samples
                avg_dy = total_dy / samples
                
                # Apply acceleration for larger movements
                magnitude = (avg_dx**2 + avg_dy**2)**0.5
                if magnitude > 5:
                    multiplier = 1 + (magnitude - 5) * 0.05 * ACCELERATION_FACTOR
                    avg_dx *= multiplier
                    avg_dy *= multiplier
                
                # Apply minimum threshold to reduce jitter
                if abs(avg_dx) > MIN_MOVEMENT_THRESHOLD or abs(avg_dy) > MIN_MOVEMENT_THRESHOLD:
                    # Apply the movement without any duration for immediate effect
                    pyautogui.moveRel(avg_dx, avg_dy, duration=0)
                
                # Clear the buffer after processing
                movement_buffer.clear()
        
        # Ensure a consistent update rate
        await asyncio.sleep(UPDATE_RATE)

async def handler(websocket):
    print("Client connected")
    try:
        async for message in websocket:
            try:
                data = json.loads(message)
                action = data.get("action")
                
                if action == "move":
                    dx = data.get("dx", 0)
                    dy = data.get("dy", 0)
                    
                    # Add movement to buffer for processing
                    movement_buffer.append((dx, dy))
                
                elif action == "click":
                    pyautogui.click()
                
                elif action == "double_click":
                    pyautogui.doubleClick()
                
                elif action == "right_click":
                    pyautogui.rightClick()
                
                else:
                    print(f"Unknown action: {data}")
            
            except json.JSONDecodeError:
                print(f"Invalid JSON received: {message}")
    
    except websockets.exceptions.ConnectionClosed:
        print("Client disconnected")

async def main():
    # Disable pyautogui failsafe for continuous operation
    pyautogui.FAILSAFE = False
    
    # Set pyautogui settings for better performance
    pyautogui.PAUSE = 0  # Remove default pause between commands
    
    # Start the movement processor task
    movement_task = asyncio.create_task(movement_processor())
    
    # Start the websocket server
    server = await websockets.serve(
        handler, 
        "192.168.1.100", 
        44213, 
        max_queue=None,
        ping_interval=None,
        ping_timeout=None,
        close_timeout=10
    )
    
    print("WebSocket server started on ws://192.168.1.100:44213")
    
    try:
        await server.wait_closed()
    finally:
        movement_task.cancel()
        try:
            await movement_task
        except asyncio.CancelledError:
            pass

if __name__ == "__main__":
    asyncio.run(main())