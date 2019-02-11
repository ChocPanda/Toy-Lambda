const { SES } = require("aws-sdk");

const sourceAddr = process.env.SOURCE_ADDR;
const destAddr = JSON.parse(process.env.DESTINATION_ADDR);
const replyAddr = JSON.parse(process.env.REPLY_ADDR);

exports.handler = (event, context, callback) => {
  Promise.all(
    event.Records.map(record => {
      const mailOptions = {
        Destination: {
          ToAddresses: destAddr
        },
        Message: {
          Body: {
            Html: {
              Charset: "UTF-8",
              Data: `<p>There's a new file in the bucket: ${
                record.s3.bucket.name
                }, called: ${record.s3.object.key}</p>`
            }
          },
          Subject: {
            Charset: "UTF-8",
            Data: "AUTOMATED: New Object"
          }
        },
        Source: sourceAddr,
        ReplyToAddresses: replyAddr
      };

      const mailer = new SES({ apiVersion: "2010-12-01" });

      return mailer
        .sendEmail(mailOptions)
        .promise()
        .then(data => callback(null, { event, context, data }))
        .catch(err => callback(err, { event, context }));
    })
  );
};
