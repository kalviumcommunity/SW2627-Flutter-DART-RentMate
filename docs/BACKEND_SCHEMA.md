# RentMate Backend Schema

## Collections

### users/{userId}
- name: string
- email: string
- role: coordinator | warehouse | admin
- active: boolean

### equipment/{equipmentId}
- name: string
- sku: string
- category: string
- totalQuantity: number
- rentableQuantity: number
- active: boolean
- condition: string

### bookings/{bookingId}
- eventName: string
- customerName: string
- phoneNumber: string
- venue: string
- eventType: string
- startAt: timestamp
- endAt: timestamp
- items: [{equipmentId, quantity, unitPrice}]
- estimatedTotal: number
- status: draft | confirmed | dispatched | partially_returned | returned | cancelled
- createdBy: string
- createdAt: timestamp

### dispatches/{dispatchId}
- bookingId: string
- status: scheduled | packing | loaded
- items: [{equipmentId, requiredQuantity, packedQuantity}]
- loadedAt: timestamp
- loadedBy: string

### returns/{returnId}
- bookingId: string
- dispatchId: string
- items: [{equipmentId, returnedQuantity, damagedQuantity, missingQuantity}]
- recordedBy: string
- returnedAt: timestamp

## Relationships
- users → create/manage bookings
- bookings → contain equipment items
- bookings → have dispatches
- dispatches → have returns
- equipment → referenced by bookings and dispatches

## Business Rules
1. Start time must be before end time.
2. Quantities must be positive.
3. Cancelled bookings do not reserve stock.
4. Check overlapping bookings before confirmation.
5. Confirm reservations atomically to prevent double booking.
6. Only verified, rentable returns increase available stock.
7. Only authorized users can modify inventory and dispatches.