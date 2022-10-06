# API that returns image with detections on it
@app.route('/image/by-image-file', methods=['POST'])
def get_image_by_image_file():
  image = request.files["images"]
  image_filename = image.filename
  image_path = "./temp/" + image.filename
  image.save(os.path.join(os.getcwd(), image_path[2:]))

  try:
    original_image = cv2.imread(image_path)
    original_image = cv2.cvtColor(original_image, cv2.COLOR_BGR2RGB)

    image_data = cv2.resize(original_image, (input_size, input_size))
    image_data = image_data / 255.
  except cv2.error:
    # remove temporary image
    os.remove(image_path)
    abort(404, "it is not an image file or image file is an unsupported format. try jpg or png")
  except Exception as e:
    # remove temporary image
    os.remove(image_path)
    print(e.__class__)
    print(e)
    abort(500)

  images_data = []
  for i in range(1):
    images_data.append(image_data)
  images_data = np.asarray(images_data).astype(np.float32)

  if framework == 'tflite':
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    print(input_details)
    print(output_details)
    interpreter.set_tensor(input_details[0]['index'], images_data)
    interpreter.invoke()
    pred = [interpreter.get_tensor(output_details[i]['index']) for i in range(len(output_details))]
    if model == 'yolov3' and tiny == True:
        boxes, pred_conf = filter_boxes(pred[1], pred[0], score_threshold=0.25,
                                        input_shape=tf.constant([input_size, input_size]))
    else:
        boxes, pred_conf = filter_boxes(pred[0], pred[1], score_threshold=0.25,
                                        input_shape=tf.constant([input_size, input_size]))
  else:
    t1 = time.time()
    infer = saved_model_loaded.signatures['serving_default']
    batch_data = tf.constant(images_data)
    pred_bbox = infer(batch_data)
    for key, value in pred_bbox.items():
        boxes = value[:, :, 0:4]
        pred_conf = value[:, :, 4:]
    t2 = time.time()
    print('time: {}'.format(t2 - t1))

  t1 = time.time()
  boxes, scores, classes, valid_detections = tf.image.combined_non_max_suppression(
    boxes=tf.reshape(boxes, (tf.shape(boxes)[0], -1, 1, 4)),
    scores=tf.reshape(
        pred_conf, (tf.shape(pred_conf)[0], -1, tf.shape(pred_conf)[-1])),
    max_output_size_per_class=50,
    max_total_size=50,
    iou_threshold=iou,
    score_threshold=score
  )
  t2 = time.time()
  class_names = utils.read_class_names(cfg.YOLO.CLASSES)
  print('time: {}'.format(t2 - t1))
  for i in range(valid_detections[0]):
    print('\t{}, {}, {}'.format(class_names[int(classes[0][i])],
                                np.array(scores[0][i]),
                                np.array(boxes[0][i])))

  pred_bbox = [boxes.numpy(), scores.numpy(), classes.numpy(), valid_detections.numpy()]

  # read in all class names from config
  class_names = utils.read_class_names(cfg.YOLO.CLASSES)

  # by default allow all classes in .names file
  allowed_classes = list(class_names.values())

  # custom allowed classes (uncomment line below to allow detections for only people)
  # allowed_classes = ['person']

  image = utils.draw_bbox(original_image, pred_bbox, allowed_classes=allowed_classes)

  image = Image.fromarray(image.astype(np.uint8))

  image = cv2.cvtColor(np.array(image), cv2.COLOR_BGR2RGB)
  # Download file detected.png and save it to output folder
  cv2.imwrite(output_path + image_filename[0:len(image_filename) - 4] + '.png', image)
  # cv2.imwrite(output_path + 'detection' + '.png', image)

  # prepare image for response
  _, img_encoded = cv2.imencode('.png', image)
  response = img_encoded.tostring()

  # remove temporary image
  os.remove(image_path)
  # print(f"{image.filename}XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")

  try:
    return Response(response=response, status=200, mimetype='image/png')
  except FileNotFoundError:
    abort(404)