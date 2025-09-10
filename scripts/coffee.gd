extends Node3D
#
#@export var particle_count: int = 500
#@export var mug_interior_radius: float = 0.4
#@export var liquid_height: float = 0.3
#
#var liquid_particles: GPUParticles3D
#var is_contained: bool = true
#
#func _ready():
	#setup_liquid_particles()
#
#func setup_liquid_particles():
	#liquid_particles = GPUParticles3D.new()
	#add_child(liquid_particles)
	#
	## Basic particle setup
	#liquid_particles.emitting = true
	#liquid_particles.amount = particle_count
	#liquid_particles.lifetime = 0.0  # Persistent particles
	#liquid_particles.visibility_aabb = AABB(Vector3(-2, -2, -2), Vector3(4, 4, 4))
	#
	## Create the process material
	#var process_material = ParticleProcessMaterial.new()
	#
	## Make particles spawn in a circle inside the mug
	#process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	#process_material.emission_sphere_radius = mug_interior_radius * 0.8
	#
	## Physics
	#process_material.direction = Vector3(0, -1, 0)
	#process_material.gravity = Vector3(0, -9.8, 0)
	#process_material.initial_velocity_min = 0.0
	#process_material.initial_velocity_max = 0.0
	#
	## Appearance
	#process_material.scale_min = 0.02
	#process_material.scale_max = 0.03
	#
	#liquid_particles.process_material = process_material
	#
	## Visual appearance
	#var material = StandardMaterial3D.new()
	#material.albedo_color = Color(0.4, 0.2, 0.1, 0.9)  # Coffee color
	#material.roughness = 0.2
	#material.metallic = 0.1
	#liquid_particles.material_override = material
	#
	## Mesh for particles
	#var sphere = SphereMesh.new()
	#sphere.radius = 0.015
	#sphere.height = 0.03
	#liquid_particles.draw_pass_1 = sphere
#
## Call this when mug is tilted to make liquid spill
#func tilt_mug(tilt_angle: Vector3):
	#if liquid_particles and liquid_particles.process_material:
		#var process_mat = liquid_particles.process_material as ParticleProcessMaterial
		#
		## Apply tilt forces
		#var tilt_force = Vector3(tilt_angle.z, -9.8, -tilt_angle.x) * 2.0
		#process_mat.gravity = tilt_force
		#
		## If tilted enough, particles can escape container
		#if abs(tilt_angle.z) > 0.5 or abs(tilt_angle.x) > 0.5:
			#is_contained = false
			#enable_spilling()
#
#func enable_spilling():
	## Increase particle spread when spilling
	#if liquid_particles.process_material:
		#var process_mat = liquid_particles.process_material as ParticleProcessMaterial
		#process_mat.initial_velocity_min = 1.0
		#process_mat.initial_velocity_max = 3.0
		#process_mat.emission_sphere_radius = mug_interior_radius * 1.5
#
## Optional: Add this if you want collision detection for spilled liquid
#func setup_container_detection():
	## Create an area to detect when particles leave the mug
	#var container_area = Area3D.new()
	#add_child(container_area)
	#
	#var collision_shape = CollisionShape3D.new()
	#var box_shape = BoxShape3D.new()
	#box_shape.size = Vector3(mug_interior_radius * 2, liquid_height, mug_interior_radius * 2)
	#collision_shape.shape = box_shape
	#container_area.add_child(collision_shape)
	#
	## Connect signals if needed
	#container_area.body_exited.connect(_on_liquid_spilled)
#
#func _on_liquid_spilled(body):
	#print("Liquid spilled!")
